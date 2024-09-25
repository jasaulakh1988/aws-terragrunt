# live/shared/iam/engineering/terragrunt.hcl

terraform {
  source = "../../../../modules/core/iam/"
}

inputs = {
  aws_region       = "us-east-1"
  config_file_path = "${get_terragrunt_dir()}/iam_engineering_config.yaml"  # Points to Engineering YAML config
}

remote_state {
  backend = "s3"
  config = {
    bucket = "asp-global-tfstate-bucket"
    region = "us-east-1"
    key    = "live/shared/iam/engineering/terraform.tfstate"
  }
}

