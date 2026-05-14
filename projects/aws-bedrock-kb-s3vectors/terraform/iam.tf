resource "aws_iam_role" "this" {
  name = "${local.project_name}-bedrock-kb-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "bedrock.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "s3_docs" {
  name = "s3-docs-read"
  role = aws_iam_role.this.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = ["s3:GetObject", "s3:ListBucket"]
      Resource = [
        aws_s3_bucket.docs.arn,
        "${aws_s3_bucket.docs.arn}/*",
      ]
    }]
  })
}

resource "aws_iam_role_policy" "s3_vectors" {
  name = "s3-vectors-readwrite"
  role = aws_iam_role.this.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3vectors:GetIndex"]
        Resource = aws_s3vectors_vector_bucket.vectors.vector_bucket_arn
      },
      {
        Effect = "Allow"
        Action = [
          "s3vectors:PutVectors",
          "s3vectors:GetVectors",
          "s3vectors:DeleteVectors",
          "s3vectors:QueryVectors",
          "s3vectors:ListVectors",
        ]
        Resource = aws_s3vectors_index.this.index_arn
      },
    ]
  })
}

resource "aws_iam_role_policy" "bedrock_embed" {
  name = "bedrock-embed-invoke"
  role = aws_iam_role.this.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["bedrock:InvokeModel"]
      Resource = local.model_arn
    }]
  })
}
