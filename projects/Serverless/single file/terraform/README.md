# terraform-lambda

This project will be used to write an medium post, to provide an easy way of doing lambda with pure boto3 and terraform

Here we gonna build a project that:
- creates an s3 bucket (module)
- creates an role for a lambda be able to access the bucket read-only and able to create logs (module)
- creates lambda code that gets the LastModified parameter of an static file "input-data.csv" of that bucket 
- creates an lambda terraform module that automatically zips and ship the lambda