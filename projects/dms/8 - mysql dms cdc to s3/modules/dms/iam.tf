data "aws_iam_policy_document" "dms_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["dms.amazonaws.com"]
      type        = "Service"
    }
  }
}


data "aws_iam_policy_document" "s3_access" {
  statement {
    actions   = ["s3:*"]
    resources = ["${var.bucket["arn"]}*"]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "this" {
  name   = "nina-dms-s3-access"
  policy = data.aws_iam_policy_document.s3_access.json
}

resource "aws_iam_role" "this" {
  assume_role_policy = data.aws_iam_policy_document.dms_assume_role.json
  name               = "s3-bucket-dms-access"
}

resource "aws_iam_role_policy_attachment" "dms-access-s3" {
  policy_arn = aws_iam_policy.this.arn
  role       = aws_iam_role.this.name
}