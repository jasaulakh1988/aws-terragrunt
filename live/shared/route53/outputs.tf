# shared/route53/outputs.tf

output "zone_id" {
  value = aws_route53_zone.primary.zone_id
}

