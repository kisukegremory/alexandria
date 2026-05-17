import os
import sys
import uuid

import boto3

_DEFAULT_SESSION = str(uuid.uuid4())


def invoke_agent(message: str, session_id: str = _DEFAULT_SESSION) -> str:
    agent_id = os.environ["AGENT_ID"]
    alias_id = os.environ["AGENT_ALIAS_ID"]

    session = boto3.Session(region_name="us-east-1", profile_name="nina")
    client = session.client("bedrock-agent-runtime")

    response = client.invoke_agent(
        agentId=agent_id,
        agentAliasId=alias_id,
        sessionId=session_id,
        inputText=message,
    )

    parts = []
    for event in response["completion"]:
        chunk = event.get("chunk", {})
        if "bytes" in chunk:
            parts.append(chunk["bytes"].decode())

    return "".join(parts)


if __name__ == "__main__":
    msg = " ".join(sys.argv[1:]) if len(sys.argv) > 1 else "Olá, preciso de ajuda com TI."
    print(invoke_agent(msg))
