resource "aws_ses_receipt_rule_set" "this" {
  rule_set_name = "${var.project_name}-rule-set"
}


resource "aws_ses_receipt_rule" "this" {
  name = "${var.project_name}-receive-rule"
  rule_set_name = aws_ses_receipt_rule_set.this.rule_set_name
  recipients = ["gmail.receiver@gatosedados.com"]
  enabled = true

  s3_action {
    position = 0
    bucket_name = var.bucket_arn
    object_key_prefix = "raw/"
    iam_role_arn = aws_iam_role.this.arn
  }
}
