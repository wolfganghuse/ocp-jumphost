

resource "aws_route53_record" "PC" {
  zone_id = "Z0807287146Q4KF4CRHAX"
  name    = format("pc.%s", var.ZONE)
  type    = "A"
  ttl     = 300
  records = [var.PC_ENDPOINT]
}

resource "aws_route53_record" "Objects" {
  zone_id = "Z0807287146Q4KF4CRHAX"
  name    = format("objects.%s", var.ZONE)
  type    = "A"
  ttl     = 300
  records = [var.OBJECTS_ENDPOINT]
}
