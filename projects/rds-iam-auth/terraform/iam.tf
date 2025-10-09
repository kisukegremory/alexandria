data "aws_iam_policy_document" "this" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [ 
        "rds-db:Connect"
     ]
        resources = [
      "arn:aws:rds-db:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:dbuser:${aws_db_instance.this.resource_id}/iam_auth",
    ]
  }
}

resource "aws_iam_policy" "this" {
  name   = "${local.project_name}-db-conn-policy"
  policy = data.aws_iam_policy_document.this.json
}