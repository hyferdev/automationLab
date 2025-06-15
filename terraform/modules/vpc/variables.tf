# /terraform/modules/vpc/variables.tf
# Input variables for the VPC module.

variable "vpc_cidr" {
  description = "The main CIDR block for the VPC."
  type        = string
}

variable "public_subnet_a_cidr" {
  description = "CIDR block for the public subnet in AZ a."
  type        = string
}

variable "public_subnet_b_cidr" {
  description = "CIDR block for the public subnet in AZ b."
  type        = string
}

variable "private_subnet_a_cidr" {
  description = "CIDR block for the private subnet in AZ a."
  type        = string
}

variable "private_subnet_b_cidr" {
  description = "CIDR block for the private subnet in AZ b."
  type        = string
}

variable "project_name" {
  description = "The name of the project, used for tagging."
  type        = string
}

variable "availability_zones" {
  description = "A list of availability zones to deploy into."
  type        = list(string)
}

variable "standard_tags" {
  description = "A map of standard tags to apply to all resources."
  type        = map(string)
  default     = {}
}

variable "project_tags" {
  description = "A map of tags specific to the project."
  type        = map(string)
  default     = {}
}

variable "environment" {
  description = "The deployment environment name (e.g., dev, prod)."
  type        = string
}
