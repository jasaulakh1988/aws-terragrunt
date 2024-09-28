variable "vpc_id" {
  description = "The VPC ID"
  type        = string
}

variable "private_subnets" {
  description = "List of private subnets with servicetype"
  type        = list(object({
    subnet_id         = string
    availability_zone = string
    servicetype       = string
  }))
}

variable "instance_configurations" {
  description = "Configurations for multiple EC2 instance setups."
  type = list(object({
    team_name     = string
    service       = string
    servicetype   = string   # Ensure this matches
    instance_type = string
    ami_id        = string
    count         = number
    environment   = string
    tags          = map(string)
  }))
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "default_subnet_id" {
  description = "The default subnet ID to use if no filtered subnets are found"
  type        = string
}

