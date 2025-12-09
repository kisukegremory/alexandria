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


data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.arn]
    }
    actions = ["sts:AssumeRole"]
  }
}


resource "aws_iam_role" "this" {
  name               = "${local.project_name}-db-conn-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}

resource "null_resource" "assume_role" {
  provisioner "local-exec" {
    command = "aws sts assume-role --role-arn ${aws_iam_role.this.arn} --role-session-name ${local.project_name}"
  }
}