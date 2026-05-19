import pytest
from agents.supervisor import supervisor, find_flights, find_accommodation, find_activities


class TestFullRequest:
    """Cenário 1: request completo — supervisor chama os 3 agentes."""

    def test_returns_itinerary(self):
        reply = str(supervisor(
            "Quero ir a Lisboa em julho, 5 dias, 2 pessoas, budget médio."
        ))
        assert "lisboa" in reply.lower() or "lisbon" in reply.lower()

    def test_includes_flight_info(self):
        reply = str(supervisor(
            "Quero ir a Lisboa em julho, 5 dias, 2 pessoas, budget médio."
        ))
        assert any(kw in reply.lower() for kw in ["voo", "flight", "tap", "iberia", "latam"])

    def test_includes_hotel_info(self):
        reply = str(supervisor(
            "Quero ir a Lisboa em julho, 5 dias, 2 pessoas, budget médio."
        ))
        assert any(kw in reply.lower() for kw in ["hotel", "hospedagem", "noite", "bairro"])

    def test_includes_activities(self):
        reply = str(supervisor(
            "Quero ir a Lisboa em julho, 5 dias, 2 pessoas, budget médio."
        ))
        assert any(kw in reply.lower() for kw in ["dia", "day", "alfama", "belém", "castelo"])


class TestPartialRequestNoHotel:
    """Cenário 2: usuário já tem hotel — supervisor NÃO deve chamar find_accommodation."""

    def test_skips_accommodation(self, monkeypatch):
        called = []

        original = find_accommodation.__wrapped__ if hasattr(find_accommodation, "__wrapped__") else None

        def fake_accommodation(request: str) -> str:
            called.append("accommodation")
            return "should not be called"

        monkeypatch.setattr("agents.supervisor.accommodation_agent", lambda r: fake_accommodation(r))

        reply = str(supervisor(
            "Paris, agosto, 3 dias, 2 pessoas — já tenho onde ficar."
        ))
        assert "accommodation" not in called, "Supervisor called accommodation agent when it should not"
        assert "paris" in reply.lower()

    def test_includes_flights_and_activities(self):
        reply = str(supervisor(
            "Paris, agosto, 3 dias, 2 pessoas — já tenho onde ficar."
        ))
        assert any(kw in reply.lower() for kw in ["voo", "flight", "air france", "tap", "latam"])
        assert any(kw in reply.lower() for kw in ["dia", "day", "eiffel", "louvre", "montmartre"])


class TestActivitiesOnly:
    """Cenário 3: usuário só quer atividades — sem voo, sem hotel."""

    def test_returns_itinerary(self):
        reply = str(supervisor("O que fazer em Tokyo por 4 dias?"))
        assert "tokyo" in reply.lower() or "tóquio" in reply.lower()

    def test_includes_activities(self):
        reply = str(supervisor("O que fazer em Tokyo por 4 dias?"))
        assert any(kw in reply.lower() for kw in [
            "shibuya", "asakusa", "shinjuku", "harajuku", "senso"
        ])


class TestUnsupportedDestination:
    """Cenário 4: destino fora do mock — resposta graciosa sem erro."""

    def test_does_not_crash(self):
        reply = str(supervisor("Quero ir a Recife por uma semana."))
        assert reply  # não lança exceção e retorna algo

    def test_graceful_response(self):
        reply = str(supervisor("Quero ir a Recife por uma semana."))
        assert not any(kw in reply.lower() for kw in ["traceback", "error", "exception"])
