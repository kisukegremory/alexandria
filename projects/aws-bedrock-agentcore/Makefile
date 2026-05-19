MSG ?= Quero viajar para Lisboa em julho, 5 dias, 2 pessoas, budget médio.

.PHONY: install run test

install:
	uv sync

run:
	uv run python main.py "$(MSG)"

test:
	uv run pytest test_scenarios.py -v
