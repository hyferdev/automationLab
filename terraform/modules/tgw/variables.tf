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

variable "vpc_attachments" {
  description = "A map of VPCs to attach to the Transit Gateway. The key is a logical name for the VPC."
  type = map(object({
    attachment_id = string
    cidr_block    = string
  }))
  default = {}
}

