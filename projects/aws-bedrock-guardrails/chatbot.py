import argparse
import json
import boto3

PROFILE = "nina"
REGION  = "us-east-1"
MODEL   = "amazon.nova-lite-v1:0"

# Mensagens retornadas quando o guardrail bloqueia input ou output.
# ANONYMIZE (mascaramento de PII) não retorna essas mensagens — o modelo responde normalmente.
BLOCKED_MESSAGES = frozenset([
    "Desculpe, essa solicitação não é permitida pela nossa política de uso.",
    "Desculpe, não posso fornecer essa informação.",
])

SYSTEM_PROMPT = (
    "Você é a assistente virtual da Credix, uma fintech de crédito consignado privado. "
    "Responda apenas perguntas relacionadas a produtos e serviços da Credix. "
    "Seja direta, cordial e objetiva. Não forneça informações confidenciais de clientes."
)

session = boto3.Session(profile_name=PROFILE, region_name=REGION)
client  = session.client("bedrock-runtime")


def chat(guardrail_id: str, guardrail_version: str, message: str, show_trace: bool = False) -> bool:
    payload = {
        "messages": [{"role": "user", "content": [{"text": message}]}],
        "system": [{"text": SYSTEM_PROMPT}],
        "inferenceConfig": {"maxTokens": 512, "temperature": 0.3},
    }

    response = client.invoke_model(
        modelId=MODEL,
        guardrailIdentifier=guardrail_id,
        guardrailVersion=guardrail_version,
        trace="ENABLED" if show_trace else "DISABLED",
        body=json.dumps(payload),
    )

    body          = json.loads(response["body"].read())
    stop_reason   = body.get("stopReason", "")
    action        = body.get("amazon-bedrock-guardrailAction", "NONE")
    text          = body["output"]["message"]["content"][0]["text"]
    guardrail_trace = body.get("amazon-bedrock-trace", {}).get("guardrail", {})

    # ANONYMIZE seta action=INTERVENED mas retorna a resposta real do modelo (com PII mascarado).
    # BLOCK retorna exatamente blocked_input_messaging ou blocked_outputs_messaging.
    # Checar o texto é mais confiável que actionReason (que só existe com trace=ENABLED).
    intervened = stop_reason == "guardrail_intervened" or (action == "INTERVENED" and text in BLOCKED_MESSAGES)

    label = "BLOQUEADO" if intervened else "PERMITIDO"
    print(f"[{label}] {text}")

    if show_trace:
        print("\n--- Response Body ---")
        print(json.dumps({k: v for k, v in body.items() if k != "output"}, indent=2, ensure_ascii=False))
        if guardrail_trace:
            print("\n--- Guardrail Trace ---")
            print(json.dumps(guardrail_trace, indent=2, ensure_ascii=False))

    return intervened


def main():
    parser = argparse.ArgumentParser(description="Credix chatbot com Bedrock Guardrails")
    parser.add_argument("guardrail_id",      help="Guardrail ID (ex: abc123)")
    parser.add_argument("guardrail_version", help="Versão publicada (ex: 1)")
    parser.add_argument("message",           help="Mensagem do usuário")
    parser.add_argument("--trace", action="store_true", help="Exibir guardrail trace completo")
    args = parser.parse_args()

    chat(args.guardrail_id, args.guardrail_version, args.message, args.trace)


if __name__ == "__main__":
    main()
