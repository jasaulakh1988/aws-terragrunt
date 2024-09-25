include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/core/security"
}

dependency "network" {
  config_path = "../network"
}

inputs = {
  environment         = "dev"
  vpc_id              = dependency.network.outputs.vpc_id
  allowed_http_cidrs  = ["0.0.0.0/0"]
  common_tags = {
    Environment = "dev"
    Component   = "security"
  }
}


