# live/shared/s3/terragrunt.hcl

include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/core/s3/"
}

locals {
  environment = "shared"
  aws_region  = "us-east-1"
  # Fetch AWS account ID dynamically
  account_id  = run_cmd("aws", "sts", "get-caller-identity", "--query", "Account", "--output", "text")
}

inputs = {
  bucket_name = "my-shared-s3-bucket-${local.environment}-${local.account_id}"
  environment = local.environment
  aws_region  = local.aws_region
}

