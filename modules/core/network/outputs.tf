output "az_name_to_id_suffix" { 
  value = local.az_name_to_id_suffix
}

output "vpc_id" {
  value = aws_vpc.main.id
}

