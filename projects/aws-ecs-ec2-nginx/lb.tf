resource "aws_lb_target_group" "this" {
  name        = "${var.project_name}-target-group"
  protocol    = "HTTP"
  target_type = "instance"
  port = local.port
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id

  
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener_rule" "this" {
  listener_arn = data.terraform_remote_state.lb.outputs.https_listener_arn
  priority     = 200

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
  condition {
    host_header {
      values = ["${local.dns_name}*"]
    }
  }
  
  depends_on = [ aws_lb_target_group.this ]

  lifecycle {
    create_before_destroy = true
  }
}