# --- Assume role policies ---

data "aws_iam_policy_document" "bedrock_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["bedrock.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "lambda_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# --- KB execution role ---

resource "aws_iam_role" "kb_execution" {
  name               = "${local.project_name}-kb-role"
  assume_role_policy = data.aws_iam_policy_document.bedrock_assume.json
}

data "aws_iam_policy_document" "kb_s3_docs" {
  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:ListBucket"]
    resources = [aws_s3_bucket.docs.arn, "${aws_s3_bucket.docs.arn}/*"]
  }
}

resource "aws_iam_role_policy" "kb_s3_docs" {
  name   = "s3-docs-read"
  role   = aws_iam_role.kb_execution.id
  policy = data.aws_iam_policy_document.kb_s3_docs.json
}

data "aws_iam_policy_document" "kb_s3_vectors" {
  statement {
    effect    = "Allow"
    actions   = ["s3vectors:GetIndex"]
    resources = [aws_s3vectors_vector_bucket.vectors.vector_bucket_arn]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3vectors:PutVectors",
      "s3vectors:GetVectors",
      "s3vectors:DeleteVectors",
      "s3vectors:QueryVectors",
      "s3vectors:ListVectors",
    ]
    resources = [aws_s3vectors_index.kb_index.index_arn]
  }
}

resource "aws_iam_role_policy" "kb_s3_vectors" {
  name   = "s3-vectors-readwrite"
  role   = aws_iam_role.kb_execution.id
  policy = data.aws_iam_policy_document.kb_s3_vectors.json
}

data "aws_iam_policy_document" "kb_embed" {
  statement {
    effect    = "Allow"
    actions   = ["bedrock:InvokeModel"]
    resources = [local.embed_model]
  }
}

resource "aws_iam_role_policy" "kb_embed" {
  name   = "bedrock-embed-invoke"
  role   = aws_iam_role.kb_execution.id
  policy = data.aws_iam_policy_document.kb_embed.json
}

# --- Agent execution role ---

resource "aws_iam_role" "agent_execution" {
  name               = "${local.project_name}-agent-role"
  assume_role_policy = data.aws_iam_policy_document.bedrock_assume.json
}

data "aws_iam_policy_document" "agent_invoke_model" {
  statement {
    effect    = "Allow"
    actions   = ["bedrock:InvokeModel"]
    resources = ["arn:aws:bedrock:us-east-1::foundation-model/${local.agent_model}"]
  }
}

resource "aws_iam_role_policy" "agent_invoke_model" {
  name   = "bedrock-invoke-model"
  role   = aws_iam_role.agent_execution.id
  policy = data.aws_iam_policy_document.agent_invoke_model.json
}

data "aws_iam_policy_document" "agent_invoke_lambda" {
  statement {
    effect    = "Allow"
    actions   = ["lambda:InvokeFunction"]
    resources = [aws_lambda_function.action_groups.arn]
  }
}

resource "aws_iam_role_policy" "agent_invoke_lambda" {
  name   = "lambda-invoke"
  role   = aws_iam_role.agent_execution.id
  policy = data.aws_iam_policy_document.agent_invoke_lambda.json
}

data "aws_iam_policy_document" "agent_retrieve_kb" {
  statement {
    effect    = "Allow"
    actions   = ["bedrock:Retrieve"]
    resources = [aws_bedrockagent_knowledge_base.techcorp.arn]
  }
}

resource "aws_iam_role_policy" "agent_retrieve_kb" {
  name   = "kb-retrieve"
  role   = aws_iam_role.agent_execution.id
  policy = data.aws_iam_policy_document.agent_retrieve_kb.json
}

# --- Lambda execution role ---

resource "aws_iam_role" "lambda_execution" {
  name               = "${local.project_name}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
