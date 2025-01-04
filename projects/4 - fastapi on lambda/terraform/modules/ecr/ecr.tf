resource "aws_ecr_repository" "this" {
  name         = var.project_name
  tags         = var.commom_tags
  force_delete = true
}

resource "aws_ecr_lifecycle_policy" "my_policy" {
  repository = aws_ecr_repository.this.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep only 3 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 3
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}