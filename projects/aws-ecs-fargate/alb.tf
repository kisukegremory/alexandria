resource "aws_lb" "this" {
  name               = "nina-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb.id]
  subnets            = data.aws_subnets.default.ids
}

resource "aws_lb_target_group" "this" {
  name        = "nina-lb-target-group"
  port        = local.port
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