# /terraform/modules/compute/variables.tf

variable "instance_name" {
  description = "The name for the EC2 instance and its resources."
  type        = string
}

variable "instance_type" {
  description = "The EC2 instance type."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC to deploy the instance into."
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet for the instance."
  type        = string
}

variable "ssh_key_name" {
  description = "The name of the EC2 Key Pair for SSH access."
  type        = string
}

variable "ssh_access_cidr" {
  description = "The IP address range allowed to SSH into the instance."
  type        = string
}

variable "internal_traffic_cidrs" {
  description = "A list of CIDR blocks for internal traffic within the network."
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


