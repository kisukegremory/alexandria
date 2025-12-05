resource "aws_apprunner_service" "this" {
  service_name = replace(local.project_name, "/", "-")
  instance_configuration {
    cpu               = 256
    memory            = 512
    instance_role_arn = aws_iam_role.task.arn
  }
  source_configuration {
    auto_deployments_enabled = true

    authentication_configuration {
      access_role_arn = aws_iam_role.build.arn
    }

    image_repository {
      image_identifier      = "${aws_ecr_repository.this.repository_url}:latest"
      image_repository_type = "ECR"
      image_configuration {
        port = 8080
        runtime_environment_variables = {
          QUEUE_URL = aws_sqs_queue.this.url
        }
      }
    }
  }
}


output "app_url" {
  value = "https://${aws_apprunner_service.this.service_url}"
}
