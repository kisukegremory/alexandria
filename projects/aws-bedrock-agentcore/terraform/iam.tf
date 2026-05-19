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

resource "aws_iam_role" "agentcore_execution" {
  name               = "${local.project_name}-agentcore-role"
  assume_role_policy = data.aws_iam_policy_document.bedrock_assume.json
}

data "aws_iam_policy_document" "agentcore_invoke_models" {
  statement {
    effect  = "Allow"
    actions = ["bedrock:InvokeModel", "bedrock:InvokeModelWithResponseStream"]
    resources = [
      "arn:aws:bedrock:${local.region}::foundation-model/${local.supervisor_model}",
      "arn:aws:bedrock:${local.region}::foundation-model/${local.subagent_model}",
    ]
  }
}

resource "aws_iam_role_policy" "agentcore_invoke_models" {
  name   = "bedrock-invoke-models"
  role   = aws_iam_role.agentcore_execution.id
  policy = data.aws_iam_policy_document.agentcore_invoke_models.json
}

data "aws_iam_policy_document" "agentcore_ecr" {
  statement {
    effect  = "Allow"
    actions = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer",
    ]
    resources = [aws_ecr_repository.travel_planner.arn]
  }
}

resource "aws_iam_role_policy" "agentcore_ecr" {
  name   = "ecr-pull"
  role   = aws_iam_role.agentcore_execution.id
  policy = data.aws_iam_policy_document.agentcore_ecr.json
}
