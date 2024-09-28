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
}


resource "aws_subnet" "private" {
  for_each = { for subnet in var.private_subnets : "${subnet.availability_zone}-${subnet.servicetype}" => subnet }

  vpc_id            = var.vpc_id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone

  tags = merge(
    var.tags,
    {
      "Name"        = "private-subnet-${each.value.servicetype}-${local.az_name_to_id_suffix[each.value.availability_zone]}-${var.env}",
      "servicetype" = each.value.servicetype  # Add this line
    }
  )
}


# Create Private Route Tables
resource "aws_route_table" "private" {
  vpc_id = var.vpc_id

  tags = merge(
    var.tags,
    {
      "Name" = "private-rt-${local.region_short_code[var.region]}-${var.env}"
    }
  )
}

# Associate Private Subnets with Route Tables
resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}

# VPC Endpoints for S3 and DynamoDB
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"

  tags = merge(
    var.tags,
    {
      "Name" = "vpc-endpoint-s3-${local.region_short_code[var.region]}-${var.env}"
    }
  )
}

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region}.dynamodb"
  vpc_endpoint_type = "Gateway"

  tags = merge(
    var.tags,
    {
      "Name" = "vpc-endpoint-dynamodb-${local.region_short_code[var.region]}-${var.env}"
    }
  )
}

