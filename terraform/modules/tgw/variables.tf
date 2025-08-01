# /terraform/modules/tgw/variables.tf

variable "project_name" {
  description = "The name of the project."
  type        = string
}

variable "environment" {
  description = "The deployment environment name (e.g., dev, prod)."
  type        = string
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

variable "primary_vpc_attachment_id" {
  description = "The TGW attachment ID for the primary VPC."
  type        = string
}

variable "secondary_vpc_attachment_id" {
  description = "The TGW attachment ID for the secondary VPC."
  type        = string
}

variable "primary_vpc_cidr" {
  description = "The CIDR block of the primary VPC."
  type        = string
}

variable "secondary_vpc_cidr" {
  description = "The CIDR block of the secondary VPC."
  type        = string
}
