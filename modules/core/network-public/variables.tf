variable "vpc_id" {
  description = "VPC ID where public subnets will be created"
  type        = string
}

variable "region" {
  description = "Region for the network"
  type        = string
}

variable "env" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnets with CIDR blocks, availability zones, and services"
  type = list(object({
    cidr_block        = string
    availability_zone = string
    servicetype           = string  # Service name for the subnet
  }))
}

variable "nat_gateway_enabled" {
  description = "Boolean flag to enable NAT Gateway"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags for the resources"
  type        = map(string)
}

