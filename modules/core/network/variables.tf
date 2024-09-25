variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "region" {
  description = "Region in which the resources are created"
  type        = string
}

variable "env" {
  description = "Environment for the resources"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
}

