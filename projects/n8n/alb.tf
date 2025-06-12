
resource "aws_lb_target_group" "instance_tg" {
  name     = "${local.project_name}-tg"
  port     = 5678
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id
   health_check {
    path = "/healthz" # N8N Health Check endpoint
    matcher = "200,301,302"
  }
}