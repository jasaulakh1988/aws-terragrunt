# shared/route53/variables.tf

variable "domain_name" {
  description = "The domain name for Route 53"
  type        = string
}

variable "ip_address" {
  description = "IP address to map to the domain"
  type        = string
}

