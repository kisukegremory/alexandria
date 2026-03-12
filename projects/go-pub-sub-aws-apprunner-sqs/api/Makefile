build:
	docker build --provenance false -t serverless-interaction/api .
push:
	aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 211125621777.dkr.ecr.us-east-1.amazonaws.com
	docker tag serverless-interaction/api:latest 211125621777.dkr.ecr.us-east-1.amazonaws.com/serverless-interaction/api:latest
	docker push 211125621777.dkr.ecr.us-east-1.amazonaws.com/serverless-interaction/api:latest
sec-check:
	trivy image serverless-interaction/api:latest
sec-hardcheck:
	trivy image --exit-code 1 --severity HIGH serverless-interaction/api:latest
