data "aws_subnets" "this" {

}

data "http" "ip" {
  url = "https://ifconfig.me/ip"
}