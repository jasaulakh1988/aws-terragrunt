# outputs.tf

# Output instance details
output "instance_ids" {
  description = "List of IDs of the EC2 instances"
  value       = [for instance in aws_instance.ec2_instance : instance.id]
}

output "instance_private_ips" {
  description = "List of private IPs of the EC2 instances"
  value       = [for instance in aws_instance.ec2_instance : instance.private_ip]
}

output "instance_public_ips" {
  description = "List of public IPs of the EC2 instances"
  value       = [for instance in aws_instance.ec2_instance : instance.public_ip]
}

