output "target_group_arn" {
  value = aws_lb_target_group.instance_tg.arn
  description = "Para ser usado no load balancer"
}