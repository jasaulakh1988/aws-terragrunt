output "public_subnets" {
  description = "List of public subnets with their service type"
  value = [for subnet in aws_subnet.public : {
    subnet_id         = subnet.id,
    availability_zone = subnet.availability_zone,
    servicetype       = subnet.tags["servicetype"]  # Now this will return the correct servicetype
  }]
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value = [for subnet in aws_subnet.public : subnet.id]
}

output "nat_gateway_id" {
  description = "ID of the NAT Gateway"
  value = var.nat_gateway_enabled ? aws_nat_gateway.nat[0].id : null
}

output "nat_instance_id" {
  description = "ID of the NAT Instance"
  value = var.nat_gateway_enabled ? null : aws_instance.nat_instance[0].id
}

