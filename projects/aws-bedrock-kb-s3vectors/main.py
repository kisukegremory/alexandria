import argparse
import boto3

PROFILE = "nina"
REGION  = "us-east-1"
MODEL   = "arn:aws:bedrock:us-east-1::foundation-model/amazon.nova-pro-v1:0"

session = boto3.Session(profile_name=PROFILE, region_name=REGION)
client  = session.client("bedrock-agent-runtime")


def query(kb_id: str, question: str, top_k: int = 5) -> None:
    response = client.retrieve_and_generate(
        input={"text": question},
        retrieveAndGenerateConfiguration={
            "type": "KNOWLEDGE_BASE",
            "knowledgeBaseConfiguration": {
                "knowledgeBaseId": kb_id,
                "modelArn": MODEL,
                "retrievalConfiguration": {
                    "vectorSearchConfiguration": {
                        "numberOfResults": top_k,
                    }
                },
                "generationConfiguration": {
                    "promptTemplate": {
                        "textPromptTemplate": (
                            "Responda sempre em português, de forma clara e direta. "
                            "Use apenas as informações dos documentos abaixo. "
                            "Se a resposta não estiver nos documentos, diga explicitamente que não encontrou.\n\n"
                            "$search_results$"
                        )
                    }
                },
            },
        },
    )

    print(response["output"]["text"])

    citations = response.get("citations", [])
    if citations:
        print("\n--- Citações ---")
        for i, citation in enumerate(citations, 1):
            response_part = (
                citation.get("generatedResponsePart", {})
                .get("textResponsePart", {})
                .get("text", "")
                .strip()
                .replace("\n", " ")
            )
            print(f"\n[Citação {i}]")
            print(f"  Resposta: \"{response_part[:120]}...\"")

            refs = citation.get("retrievedReferences", [])
            for j, ref in enumerate(refs, 1):
                uri    = ref["location"]["s3Location"]["uri"]
                chunk  = ref["content"]["text"][:120].strip().replace("\n", " ")
                print(f"  [Chunk {j}] {uri}")
                print(f"            \"{chunk}...\"")


def main():
    parser = argparse.ArgumentParser(description="Query Bedrock Knowledge Base via RAG")
    parser.add_argument("kb_id", help="Knowledge Base ID (ex: YODDYVY82R)")
    parser.add_argument("question", help="Pergunta em linguagem natural")
    parser.add_argument("--top-k", type=int, default=5, help="Número de chunks retornados (padrão: 5)")
    args = parser.parse_args()

    query(args.kb_id, args.question, args.top_k)


if __name__ == "__main__":
    main()
