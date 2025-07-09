include .env

deps-update: pyproject.toml
	poetry export --only main -f requirements.txt --without-hashes > requirements.txt

code-fmt:
	poetry run ruff check --fix
	poetry run ruff format

image-build: code-fmt deps-update
	docker build -t ${PROJECT_NAME} .

image-push:
	aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin ${ECR_BASE_URL}
	docker tag ${PROJECT_NAME}:latest ${ECR_BASE_URL}/${PROJECT_NAME}:latest
	docker push ${ECR_BASE_URL}/${PROJECT_NAME}:latest	

image-deploy: code-fmt image-build image-push

fmt:
	cd terraform && terraform fmt -recursive

infra-refresh: fmt
	cd terraform && terraform apply -auto-approve && cd ../

deploy: image-deploy infra-refresh