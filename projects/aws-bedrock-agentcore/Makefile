MSG ?= Quero viajar para Lisboa em julho, 5 dias, 2 pessoas, budget médio.

.PHONY: install run test infra-init infra-plan infra-apply infra-destroy docker-build docker-push

install:
	uv sync

run:
	uv run python main.py "$(MSG)"

test:
	uv run pytest test_scenarios.py -v

infra-init:
	terraform -chdir=terraform init

infra-plan:
	terraform -chdir=terraform plan

infra-apply:
	terraform -chdir=terraform apply

infra-destroy:
	terraform -chdir=terraform destroy

docker-build:
	docker build -t travel-planner .

docker-push: docker-build
	$(eval ECR_URL=$(shell terraform -chdir=terraform output -raw ecr_url))
	aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $(ECR_URL)
	docker tag travel-planner:latest $(ECR_URL):latest
	docker push $(ECR_URL):latest
