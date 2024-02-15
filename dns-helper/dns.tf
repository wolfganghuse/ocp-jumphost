locals {
  domain = "cloudnative.nvdlab.net"
}
resource "aws_route53_record" "gptmgmt_gptnvd" {
  zone_id = var.ZONE_ID
  name    = format("*.%s.%s",var.subdomain,local.domain)
  type    = "A"
  ttl     = 300
  records = [var.ip]
}