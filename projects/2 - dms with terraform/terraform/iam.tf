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
    resources = ["${aws_s3_bucket.this.arn}*"]
    effect    = "Allow"
  }
}


resource "aws_iam_policy" "dms_s3_access" {
  name   = "dms_s3_access"
  policy = data.aws_iam_policy_document.s3_access.json
}

resource "aws_iam_role" "dms-access-for-endpoint" {
  assume_role_policy = data.aws_iam_policy_document.dms_assume_role.json
  name               = "dms-access-for-endpoint"
}

resource "aws_iam_role_policy_attachment" "dms-access-s3" {
  policy_arn = aws_iam_policy.dms_s3_access.arn
  role       = aws_iam_role.dms-access-for-endpoint.name
}