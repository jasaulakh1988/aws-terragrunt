# modules/cloudtrail/variables.tf

variable "cloudtrail_name" {
  description = "The name of the CloudTrail"
  type        = string
  default     = "default-cloudtrail"
}

variable "s3_bucket_name" {
  description = "S3 bucket name for CloudTrail logs"
  type        = string
}

variable "enable_cloudwatch_logging" {
  description = "Whether to enable CloudWatch logging for CloudTrail"
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "aws_region" {
  description = "The AWS region where CloudTrail will be set up"
  type        = string
}

