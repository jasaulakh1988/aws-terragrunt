include {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = "../network"  # Fetch VPC ID from the shared VPC module
}

terraform {
  source = "../../../modules/core/network-public"
}

inputs = {
  vpc_id            = dependency.vpc.outputs.vpc_id
  region            = "us-east-1"
  env               = "dev"

  public_subnets = [
    { cidr_block = "10.0.254.0/24", availability_zone = "us-east-1a", service = "default" },
    { cidr_block = "10.0.255.0/24", availability_zone = "us-east-1b", service = "default" }
  ]

  nat_gateway_enabled = false  # Change to false to use NAT Instance instead of NAT Gateway

  tags = {
    "Environment" = "dev"
    "Component"   = "network"
  }
}

