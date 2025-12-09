data "aws_ecr_image" "this" {
  repository_name = local.project_name
  image_tag       = "latest"
}
