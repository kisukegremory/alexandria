
psql-install:
	sudo apt install postgresql-client-common
	sudo apt install postgresql-client
	which psql

get_resource:
	aws rds describe-db-instances --query "DBInstances[*].[DBInstanceIdentifier,DbiResourceId]" --region us-east-2