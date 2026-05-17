resource "aws_s3vectors_vector_bucket" "vectors" {
  vector_bucket_name = "${local.project_name}-vectors"
}

resource "aws_s3vectors_index" "kb_index" {
  vector_bucket_name = aws_s3vectors_vector_bucket.vectors.vector_bucket_name
  index_name         = "kb-index"
  data_type          = "float32"
  dimension          = 1024
  distance_metric    = "cosine"
}

resource "aws_bedrockagent_knowledge_base" "techcorp" {
  name     = "${local.project_name}-kb"
  role_arn = aws_iam_role.kb_execution.arn

  knowledge_base_configuration {
    type = "VECTOR"
    vector_knowledge_base_configuration {
      embedding_model_arn = local.embed_model
    }
  }

  storage_configuration {
    type = "S3_VECTORS"
    s3_vectors_configuration {
      vector_bucket_arn = aws_s3vectors_vector_bucket.vectors.vector_bucket_arn
      index_name        = aws_s3vectors_index.kb_index.index_name
    }
  }
}

resource "aws_bedrockagent_data_source" "docs" {
  name              = "s3-docs"
  knowledge_base_id = aws_bedrockagent_knowledge_base.techcorp.id

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
        max_tokens         = 200
        overlap_percentage = 10
      }
    }
  }
}
