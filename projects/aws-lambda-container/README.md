# Lambda Docker Container

This repo is to be a base for create new projects with lambda and containers, base components:

1. create an ECR repo in the cloud before
2. upload the image via aws cli, the instructions are given in the ECR
3. reference the ecr repo in the terraform on the data image and them voilá you can run deploy with a simple `terraform apply`
4. if you need to access other aws service create and attach the policy to the current role!


