import re
import sys
import uuid

from agent import invoke_agent

GREEN = "\033[32m"
RED = "\033[31m"
RESET = "\033[0m"


def run(label: str, message: str, session_id: str | None = None,
        expect: list[str] | None = None, reject: list[str] | None = None) -> tuple[str, str, bool]:
    sid = session_id or str(uuid.uuid4())
    try:
        reply = invoke_agent(message, session_id=sid)
        print(f"\n{'='*60}")
        print(f"[{label}]")
        print(f"  MSG:   {message[:120]}")
        print(f"  REPLY: {reply[:300]}")

        passed = True
        for kw in (expect or []):
            if kw.lower() not in reply.lower():
                print(f"  MISSING '{kw}'")
                passed = False
        for kw in (reject or []):
            if kw.lower() in reply.lower():
                print(f"  UNEXPECTED '{kw}'")
                passed = False

        status = f"{GREEN}PASS{RESET}" if passed else f"{RED}FAIL{RESET}"
        print(f"  {status}")
        return reply, sid, passed
    except Exception as exc:
        print(f"\n[{label}] {RED}ERROR{RESET}: {exc}")
        return "", sid or str(uuid.uuid4()), False


def main() -> None:
    results: list[bool] = []

    # 1. KB hit — VPN problem has documented solution, agent should NOT create a ticket
    _, _, ok = run(
        "1. KB Hit — VPN",
        "Minha VPN não está conectando. O que devo fazer?",
        expect=["vpn"],
        reject=["TK-"],
    )
    results.append(ok)

    # 2. KB miss — unknown hardware issue → agent creates ticket
    reply2, _, ok = run(
        "2. KB Miss → create_ticket",
        "Meu teclado parou de funcionar completamente após atualizar o driver ontem à noite.",
        expect=["TK-"],
    )
    results.append(ok)

    m = re.search(r"TK-\d+", reply2, re.IGNORECASE)
    ticket_id = m.group(0).upper() if m else "TK-001"

    # 3. Status check
    _, _, ok = run(
        "3. get_ticket_status",
        f"Qual é o status do ticket {ticket_id}?",
        expect=[ticket_id, "OPEN"],
    )
    results.append(ok)

    # 4. Escalation
    _, _, ok = run(
        "4. escalate_ticket",
        f"O problema do ticket {ticket_id} não foi resolvido. Quero escalar para Nível 2.",
        expect=["escalad", ticket_id],
    )
    results.append(ok)

    # 5. Multi-turn — single session: create → status → escalate without repeating IDs
    sid = str(uuid.uuid4())

    reply5a, _, ok5a = run(
        "5a. Multi-turn: create",
        "Meu monitor externo não é detectado após trocar o cabo HDMI.",
        expect=["TK-"],
        session_id=sid,
    )
    results.append(ok5a)

    m5 = re.search(r"TK-\d+", reply5a, re.IGNORECASE)
    tid5 = m5.group(0).upper() if m5 else "TK-002"

    _, _, ok5b = run(
        "5b. Multi-turn: status (same session)",
        f"Qual o status do chamado {tid5}?",
        expect=[tid5],
        session_id=sid,
    )
    results.append(ok5b)

    _, _, ok5c = run(
        "5c. Multi-turn: escalate (same session)",
        f"Quero escalar o ticket {tid5}, o problema está impedindo meu trabalho.",
        expect=["escalad"],
        session_id=sid,
    )
    results.append(ok5c)

    passed = sum(results)
    total = len(results)
    print(f"\n{'='*60}")
    print(f"Results: {passed}/{total} passed")
    sys.exit(0 if passed == total else 1)


if __name__ == "__main__":
    main()
