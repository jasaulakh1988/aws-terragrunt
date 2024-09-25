variable "private_subnets" {
  description = "List of private subnets with CIDR blocks, availability zones, and services"
  type = list(object({
    cidr_block        = string
    availability_zone = string
    service           = string  # Add service field
  }))
}

variable "vpc_id" {
  description = "ID of the VPC"
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

