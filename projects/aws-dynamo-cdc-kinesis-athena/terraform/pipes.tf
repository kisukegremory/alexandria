# ------------------------------------------------------------------------------
# IAM ROLE PARA O EVENTBRIDGE PIPES
# ------------------------------------------------------------------------------
data "aws_iam_policy_document" "pipe_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["pipes.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "pipe_role" {
  name               = "alexandria-pipe-role-${local.project_name}"
  assume_role_policy = data.aws_iam_policy_document.pipe_assume_role.json
}

# Permissões: Ler do DynamoDB Stream e Escrever no Firehose
data "aws_iam_policy_document" "pipe_policy" {
  statement {
    actions = [
      "dynamodb:DescribeStream",
      "dynamodb:GetRecords",
      "dynamodb:GetShardIterator",
      "dynamodb:ListStreams"
    ]
    resources = [aws_dynamodb_table.user_source.stream_arn]
  }

  statement {
    actions = [
      "firehose:PutRecord",
      "firehose:PutRecordBatch"
    ]
    resources = [aws_kinesis_firehose_delivery_stream.to_datalake.arn]
  }
}

resource "aws_iam_role_policy" "pipe_policy" {
  name   = "alexandria-pipe-policy"
  role   = aws_iam_role.pipe_role.id
  policy = data.aws_iam_policy_document.pipe_policy.json
}


resource "aws_pipes_pipe" "dynamo_to_firehose" {
  name     = "alexandria-dynamo-cdc-to-datalake"
  role_arn = aws_iam_role.pipe_role.arn

  source = aws_dynamodb_table.user_source.stream_arn
  target = aws_kinesis_firehose_delivery_stream.to_datalake.arn

  source_parameters {
    dynamodb_stream_parameters {
      starting_position      = "LATEST"
      batch_size             = 10
      maximum_retry_attempts = 3
    }
  }

  target_parameters {
    input_template = <<-EOT
    {
      "id": "<$.dynamodb.Keys.user_id.S>",
      "event_type": "<$.eventName>",
      "timestamp": "<$.dynamodb.ApproximateCreationDateTime>"
    }
    EOT 
  }

}
