# Bases para o projeto

## Site
upload-html:
	aws s3 cp site/index.html s3://$(shell cd bucket && terraform output -raw bucket_name)/
	@echo "upload done"

# Bucket
bucket_create:
	cd bucket && terraform init && terraform apply --auto-approve

bucket_destroy:
	cd bucket && terraform init && terraform destroy --auto-approve

# Tornar o bucket público
make_bucket_public:
	cd public_avaiability && terraform init && terraform apply --auto-approve

make_bucket_private:
	cd public_avaiability && terraform init && terraform destroy --auto-approve

# Cloudfront OAC
cloudfront-create:
	cd cloudfront_oac && terraform init && terraform apply --auto-approve

cloudfront-destroy:
	cd cloudfront_oac && terraform init && terraform destroy --auto-approve



# Comandos para subir os projetos como um todo

# S3 Site
s3-web-setup: bucket_create upload-html make_bucket_public

s3-web-destroy: make_bucket_private bucket_destroy

# Cloudfront OAC Site
cloudfront-site-setup: bucket_create upload-html cloudfront-create

cloudfront-site-destroy: cloudfront-destroy bucket_destroy
