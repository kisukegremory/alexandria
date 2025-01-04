data "aws_ecr_image" "this" {
  repository_name = aws_ecr_repository.this.name
  image_tag       = "latest"
  depends_on      = [aws_ecr_repository.this, aws_ecr_lifecycle_policy.my_policy]
}