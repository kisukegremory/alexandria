resource "aws_cloudwatch_log_group" "nginx_log_group" {
  name              = "/ecs/nginx-app"
  retention_in_days = 7 # Tempo de retenção dos logs
}