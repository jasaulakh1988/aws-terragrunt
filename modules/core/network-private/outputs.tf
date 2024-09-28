output "private_subnets" {
  description = "List of private subnets with their service type"
  value = [for subnet in aws_subnet.private : {
    subnet_id         = subnet.id,
    availability_zone = subnet.availability_zone,
    servicetype       = subnet.tags["servicetype"]  # Now this will return the correct servicetype
  }]
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value = [for subnet in aws_subnet.private : subnet.id]
}

output "private_route_table_id" {
  description = "ID of the private route table"
  value = aws_route_table.private.id
}

output "vpc_id" {
  description = "VPC ID"
  value       = var.vpc_id  # Reference the VPC ID from the passed input
}

