import re
import uuid

import pytest

from agent import invoke_agent


# Shared mutable state within each test class — fixtures are class-scoped so
# each class gets its own instance, preserving test isolation between classes.

@pytest.fixture(scope="class")
def ticket_state():
    return {"ticket_id": None}


@pytest.fixture(scope="class")
def multiturn_state():
    return {"session_id": str(uuid.uuid4()), "ticket_id": None}


class TestSingleTurn:
    """Tests 1–4: independent sessions, sequential ticket lifecycle."""

    def test_kb_hit_vpn(self):
        reply = invoke_agent(
            "Minha VPN não está conectando. O que devo fazer?",
            session_id=str(uuid.uuid4()),
        )
        assert "vpn" in reply.lower(), f"Expected VPN guidance, got: {reply}"
        assert "TK-" not in reply.upper(), f"KB hit should not create a ticket, got: {reply}"

    def test_kb_miss_creates_ticket(self, ticket_state):
        reply = invoke_agent(
            "Meu teclado parou de funcionar completamente após atualizar o driver ontem à noite.",
            session_id=str(uuid.uuid4()),
        )
        m = re.search(r"TK-\d+", reply, re.IGNORECASE)
        assert m, f"Expected a ticket ID (TK-XXX) in reply: {reply}"
        ticket_state["ticket_id"] = m.group(0).upper()

    def test_get_ticket_status(self, ticket_state):
        tid = ticket_state["ticket_id"]
        assert tid, "ticket_id missing — test_kb_miss_creates_ticket must run first"
        reply = invoke_agent(
            f"Qual é o status do ticket {tid}?",
            session_id=str(uuid.uuid4()),
        )
        assert tid in reply, f"Expected ticket ID {tid} in reply: {reply}"
        assert "open" in reply.lower(), f"Expected status OPEN in reply: {reply}"

    def test_escalate_ticket(self, ticket_state):
        tid = ticket_state["ticket_id"]
        assert tid, "ticket_id missing — test_kb_miss_creates_ticket must run first"
        reply = invoke_agent(
            f"O problema do ticket {tid} não foi resolvido. Quero escalar para Nível 2.",
            session_id=str(uuid.uuid4()),
        )
        assert "escalad" in reply.lower(), f"Expected escalation confirmation in reply: {reply}"
        assert tid in reply, f"Expected ticket ID {tid} in reply: {reply}"


class TestMultiTurn:
    """Test 5: single session across create → status → escalate turns."""

    def test_create_ticket(self, multiturn_state):
        reply = invoke_agent(
            "Meu monitor externo não é detectado após trocar o cabo HDMI.",
            session_id=multiturn_state["session_id"],
        )
        m = re.search(r"TK-\d+", reply, re.IGNORECASE)
        assert m, f"Expected a ticket ID (TK-XXX) in reply: {reply}"
        multiturn_state["ticket_id"] = m.group(0).upper()

    def test_status_same_session(self, multiturn_state):
        tid = multiturn_state["ticket_id"]
        assert tid, "ticket_id missing — test_create_ticket must run first"
        reply = invoke_agent(
            f"Qual o status do chamado {tid}?",
            session_id=multiturn_state["session_id"],
        )
        assert tid in reply, f"Expected ticket ID {tid} in reply: {reply}"

    def test_escalate_same_session(self, multiturn_state):
        tid = multiturn_state["ticket_id"]
        assert tid, "ticket_id missing — test_create_ticket must run first"
        reply = invoke_agent(
            f"Quero escalar o ticket {tid}, o problema está impedindo meu trabalho.",
            session_id=multiturn_state["session_id"],
        )
        assert "escalad" in reply.lower(), f"Expected escalation confirmation in reply: {reply}"
