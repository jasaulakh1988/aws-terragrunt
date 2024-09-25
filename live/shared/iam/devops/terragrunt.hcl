# live/shared/iam/terragrunt.hcl

terraform {
  source = "../../../../modules/core/iam/"
}

inputs = {
  aws_region       = "us-east-1"
  config_file_path = "${get_terragrunt_dir()}/iam_devops_config.yaml"
}

remote_state {
  backend = "s3"
  config = {
    bucket = "asp-global-tfstate-bucket"
    region = "us-east-1"
    key    = "live/shared/iam/devops/terraform.tfstate"
  }
}

#dependency "cloudtrail" {
#  config_path = "../../shared/cloudtrail"
#}
