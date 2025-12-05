
push:
	aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 211125621777.dkr.ecr.us-east-1.amazonaws.com
	docker build --provenance false -t serverless-interaction/api .
	docker tag serverless-interaction/api:latest 211125621777.dkr.ecr.us-east-1.amazonaws.com/serverless-interaction/api:latest
	docker push 211125621777.dkr.ecr.us-east-1.amazonaws.com/serverless-interaction/api:latest
