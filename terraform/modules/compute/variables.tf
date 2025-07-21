# /terraform/modules/compute/variables.tf

variable "instance_name" {
  description = "The name for the EC2 instance and its resources."
  type        = string
}

variable "instance_os" {
  description = "The operating system for the EC2 instances. Valid options are 'debian' or 'ubuntu'."
  type        = string
  default     = "ubuntu"
  validation {
    condition     = contains(["debian", "ubuntu"], var.instance_os)
    error_message = "The instance_os must be either 'debian' or 'ubuntu'."
  }
}

variable "instance_type" {
  description = "The EC2 instance type."
  type        = string
}

variable "instance_disk_size" {
  description = "The size of the root block device in GB."
  type        = number
}

variable "private_ip" {
  description = "The primary private IP address to associate with the instance."
  type        = string
  default     = null
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

variable "vpc_security_group_ids" {
  description = "A list of security group IDs to associate with the instance."
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


