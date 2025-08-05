# /terraform/variables.tf
# These are the variables for the root module.

variable "natasha_vpc_cidr" {
  description = "The main CIDR block for the VPC."
  type        = string
  default     = "10.15.0.0/20"
}

variable "natasha_public_subnet_a_cidr" {
  description = "CIDR block for the public subnet in AZ a."
  type        = string
  default     = "10.15.1.0/24"
}

variable "natasha_public_subnet_b_cidr" {
  description = "CIDR block for the public subnet in AZ b."
  type        = string
  default     = "10.15.2.0/24"
}

variable "natasha_private_subnet_a_cidr" {
  description = "CIDR block for the private subnet in AZ a."
  type        = string
  default     = "10.15.10.0/24"
}

variable "natasha_private_subnet_b_cidr" {
  description = "CIDR block for the private subnet in AZ b."
  type        = string
  default     = "10.15.20.0/24"
}


