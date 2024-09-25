variable "environment" {
  description = "Deployment environment (e.g., dev, stg, prd)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the security group will be created"
  type        = string
}

variable "allowed_http_cidrs" {
  description = "List of CIDR blocks allowed to access HTTP"
  type        = list(string)
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
}

