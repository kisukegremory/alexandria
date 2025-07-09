output "security_group_id" {
    value = aws_security_group.lb.id
}

output "alb_dns_name" {
    value = aws_lb.this.dns_name
}

output "alb_zone_id" {
  value = aws_lb.this.zone_id
}

output "alb_arn" {
    value = aws_lb.this.arn
}

output "https_listener_arn" {
    value = aws_lb_listener.https.arn
    description = "to be used on listener rules with host header specified as 'workflows.nina.live*'"
}