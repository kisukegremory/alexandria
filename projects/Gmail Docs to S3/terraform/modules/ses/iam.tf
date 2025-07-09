data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["ses.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "this" {
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  name               = "${var.project_name}-ses-receive-role"
}

### Policy

data "aws_iam_policy_document" "s3_access" {
  statement {
    actions   = ["s3:PutObject"]
    resources = ["${var.bucket_arn}/*"]
    effect    = "Allow"
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = [var.bucket_arn]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "this" {
  name   = "${var.project_name}-ses-receive-policy"
  policy = data.aws_iam_policy_document.s3_access.json
}

resource "aws_iam_role_policy_attachment" "this" {
  policy_arn = aws_iam_policy.this.arn
  role       = aws_iam_role.this.name
}