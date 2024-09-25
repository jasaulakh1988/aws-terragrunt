# shared/route53/main.tf
# Route 53 resource configuration shared across environments.

resource "aws_route53_zone" "primary" {
  name = var.domain_name
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "www"
  type    = "A"
  ttl     = "300"
  records = [var.ip_address]
}

