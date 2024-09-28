include {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = "../network"  # Path to the VPC module
}

terraform {
  source = "../../../modules/core/network-private"  # Pointing to the private network module
}

inputs = {
  vpc_id          = dependency.vpc.outputs.vpc_id  # Reference the VPC ID from the shared VPC module
  region          = "us-east-1"
  env             = "dev"
  private_subnets = [
    { cidr_block = "10.0.0.0/21", availability_zone = "us-east-1a", servicetype = "ec2" },
    { cidr_block = "10.0.8.0/21", availability_zone = "us-east-1b", servicetype = "ec2" },
    { cidr_block = "10.0.16.0/23", availability_zone = "us-east-1a", servicetype = "dbs" },
    { cidr_block = "10.0.18.0/23", availability_zone = "us-east-1b", servicetype = "dbs" }
  ]

  tags = {
    "Environment" = "dev"
    "Component"   = "network"
  }
}

