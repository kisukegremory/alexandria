
upload-html:
	aws s3 cp site/index.html s3://$(shell cd bucket && terraform output -raw bucket_name)/
	@echo "upload done"

bucket_create:
	cd bucket && terraform init && terraform apply --auto-approve

bucket_destroy:
	cd bucket && terraform init && terraform destroy --auto-approve

make_bucket_public:
	cd public_avaiability && terraform init && terraform apply --auto-approve

make_bucket_private:
	cd public_avaiability && terraform init && terraform destroy --auto-approve

complete-setup: bucket_create upload-html make_bucket_public

complete-destroy: make_bucket_private bucket_destroy

complete-reset: complete-destroy complete-setup