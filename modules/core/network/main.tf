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

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    var.tags,
    {
      "Name" = "vpc-${local.region_short_code[var.region]}-${var.env}"  # Using short code for the region
    }
  )
}

