resource "aws_bedrockagent_knowledge_base" "this" {
  name     = "${local.project_name}-knowledge-base"
  role_arn = aws_iam_role.this.arn

  knowledge_base_configuration {
    type = "VECTOR"
    vector_knowledge_base_configuration {
      embedding_model_arn = local.model_arn
    }
  }

  storage_configuration {
    type = "S3_VECTORS"
    s3_vectors_configuration {
      vector_bucket_arn = aws_s3vectors_vector_bucket.vectors.vector_bucket_arn
      index_name        = aws_s3vectors_index.this.index_name
    }
  }
}

resource "aws_bedrockagent_data_source" "docs" {
  name              = "s3-docs"
  knowledge_base_id = aws_bedrockagent_knowledge_base.this.id

  data_source_configuration {
    type = "S3"
    s3_configuration {
      bucket_arn = aws_s3_bucket.docs.arn
    }
  }

  vector_ingestion_configuration {
    chunking_configuration {
      chunking_strategy = "FIXED_SIZE"
      fixed_size_chunking_configuration {
        max_tokens         = 150
        overlap_percentage = 10
      }
    }
  }
}
