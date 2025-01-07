resource "aws_lb" "this" {
  name               = "${local.project_name}-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [module.sg.lb_id]
  subnets            = data.aws_subnets.default.ids
}

resource "aws_lb_target_group" "this" {
  name        = "${local.project_name}-target-group"
  port        = local.metabase_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_default_vpc.default.id
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}