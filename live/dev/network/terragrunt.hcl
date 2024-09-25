include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/core/network/"
}

inputs = {
  vpc_cidr = "10.0.0.0/16"  # CIDR range for your VPC
  region   = "us-east-1"     # Pass region for naming convention
  env      = "dev"           # Environment name for naming convention

  tags = {
    "Environment" = "dev"
    "Component"     = "network"
  }
}

