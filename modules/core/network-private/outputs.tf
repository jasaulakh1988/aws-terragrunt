output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value = [for subnet in aws_subnet.private : subnet.id]
}

output "private_route_table_id" {
  description = "ID of the private route table"
  value = aws_route_table.private.id
}

