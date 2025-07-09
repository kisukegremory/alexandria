code-fmt:
	poetry run ruff check --fix
	poetry run ruff format


deps-update: pyproject.toml
	poetry export --only main -f requirements.txt --without-hashes > requirements.txt
