resource "aws_iam_role" "kb_execution" {
  name = "${local.project_name}-kb-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "bedrock.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "kb_s3_docs" {
  name = "s3-docs-read"
  role = aws_iam_role.kb_execution.id

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

resource "aws_iam_role_policy" "kb_s3_vectors" {
  name = "s3-vectors-readwrite"
  role = aws_iam_role.kb_execution.id

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
        Resource = aws_s3vectors_index.kb_index.index_arn
      },
    ]
  })
}

resource "aws_iam_role_policy" "kb_embed" {
  name = "bedrock-embed-invoke"
  role = aws_iam_role.kb_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["bedrock:InvokeModel"]
      Resource = local.embed_model
    }]
  })
}

resource "aws_iam_role" "agent_execution" {
  name = "${local.project_name}-agent-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "bedrock.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "agent_invoke_model" {
  name = "bedrock-invoke-model"
  role = aws_iam_role.agent_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["bedrock:InvokeModel"]
      Resource = "arn:aws:bedrock:us-east-1::foundation-model/${local.agent_model}"
    }]
  })
}

resource "aws_iam_role_policy" "agent_invoke_lambda" {
  name = "lambda-invoke"
  role = aws_iam_role.agent_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["lambda:InvokeFunction"]
      Resource = aws_lambda_function.action_groups.arn
    }]
  })
}

resource "aws_iam_role_policy" "agent_retrieve_kb" {
  name = "kb-retrieve"
  role = aws_iam_role.agent_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["bedrock:Retrieve"]
      Resource = aws_bedrockagent_knowledge_base.techcorp.arn
    }]
  })
}

resource "aws_iam_role" "lambda_execution" {
  name = "${local.project_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
