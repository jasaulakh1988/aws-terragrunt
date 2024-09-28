terraform {
  backend "s3" {}
}

# Data source to get available availability zones and their IDs
data "aws_availability_zones" "available" {
  state = "available"
}

# Local map to convert region names to short codes
locals {
  region_short_code = {
    "us-east-1" = "use1"
    "us-west-2" = "usw2"
    # Add other regions as needed
  }

  az_name_to_id_suffix = {
    for idx, az in data.aws_availability_zones.available.names :
    az => replace(data.aws_availability_zones.available.zone_ids[idx], "${var.region}-", "")
  }

  # Loop through configurations to filter subnets based on ServiceType
  filtered_subnets_by_service_type = {
    for idx, config in var.instance_configurations :
    idx => [
      for subnet in var.private_subnets :
      subnet if subnet.servicetype == config.servicetype  # Use 'servicetype'
    ]
  }
}

# Create EC2 instances based on instance_configurations
resource "aws_instance" "ec2_instance" {
  count = sum([for config in var.instance_configurations : config.count]) # Sum of counts across all configurations

  ami                         = var.instance_configurations[count.index].ami_id
  instance_type               = var.instance_configurations[count.index].instance_type

  # Ensure the filtered subnets exist before assigning the subnet
  subnet_id = (
    length(local.filtered_subnets_by_service_type[count.index]) > 0 ?
    element(
      [for subnet in local.filtered_subnets_by_service_type[count.index] : subnet.subnet_id],
      count.index % length(local.filtered_subnets_by_service_type[count.index])
    ) :
    var.default_subnet_id
  )

  associate_public_ip_address = false  # Assuming private instances

  # Dynamic tags based on the team, service, and instance count
  tags = merge(
    var.instance_configurations[count.index].tags,
    {
      "Name" = "${var.instance_configurations[count.index].team_name}-${var.instance_configurations[count.index].service}-${count.index + 1}-${element([for subnet in local.filtered_subnets_by_service_type[count.index] : subnet.availability_zone], count.index % length(local.filtered_subnets_by_service_type[count.index]))}-${var.instance_configurations[count.index].environment}",
      "servicetype" = var.instance_configurations[count.index].servicetype,  # Lowercase key
      "Team"        = var.instance_configurations[count.index].team_name
    }
  )

  # Optional: User data for provisioning
  user_data = file("${path.module}/user_data.sh")
}

