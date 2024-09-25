# shared/cloudtrail/terragrunt.hcl

terraform {
  source = "../modules/core/cloudtrail"
}

inputs = {
  aws_region  = "us-east-1"
  cloudtrail_name            = "shared-cloudtrail"
  s3_bucket_name             = "shared-cloudtrail-logs-bucket"
  enable_cloudwatch_logging  = true
  tags = {
    "Environment" = "shared"
    "Project"     = "CloudTrail"
  }
}

remote_state {
  backend = "s3"
  config = {
    bucket = "asp-global-tfstate-bucket"
    region = "us-east-1"
    key    = "shared/cloudtrail/terraform.tfstate"
  }
}

