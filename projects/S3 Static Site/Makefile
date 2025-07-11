
upload-html:
	aws s3 cp site/index.html s3://$(shell cd bucket && terraform output -raw bucket_name)/
	@echo "upload done"