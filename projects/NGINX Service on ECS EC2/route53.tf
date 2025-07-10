resource "aws_route53_record" "this" {
  zone_id = data.aws_route53_zone.live.zone_id
  name    = local.dns_name
  type    = "A"
  alias {
    name                   = data.terraform_remote_state.lb.outputs.alb_dns_name
    zone_id                = data.terraform_remote_state.lb.outputs.alb_zone_id
    evaluate_target_health = true
  }
}