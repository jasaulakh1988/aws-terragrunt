# modules/iam/variables.tf

variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
}

variable "config_file_path" {
  description = "Path to the YAML file containing IAM configuration"
  type        = string
}

