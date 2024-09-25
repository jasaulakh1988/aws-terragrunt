# terragrunt.hcl at the root

remote_state {
  backend = "s3"
  config = {
    bucket         = "asp-global-tfstate-bucket"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "aws" {
  region = "${local.aws_region}"
}
EOF
}

locals {
  aws_region = "us-east-1"
  global_tag = "asp"
}

inputs = {
  aws_region = local.aws_region
  global_tag = local.global_tag
}

