# /terraform/variables.tf
# These are the variables for the root module.

variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "The name of the project."
  type        = string
  default     = "automationLab"
}

variable "availability_zones" {
  description = "A list of availability zones to deploy into."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "management_cidr" {
  description = "The IP address range allowed for SSH access."
  type        = string
  sensitive   = true
}

# --- Tagging Variables ---
variable "standard_tags" {
  description = "Standard tags to apply to all resources."
  type        = map(string)
  default = {
    owner         = "DBanyeretse"
    costCenter    = "IT3125"
    backup        = "false"
    compliance    = "internal"
    securityLevel = "public"
    ManagedBy     = "Terraform"
  }
}

variable "project_tags" {
  description = "Tags specific to this project."
  type        = map(string)
  default = {
    repository = "automationLab"
  }
}

variable "environment" {
  description = "The deployment environment name (e.g., dev, prod), derived from the Git branch."
  type        = string
}

# --- Network CIDR Variables ---
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

variable "secondary_vpc_cidr" {
  description = "The main CIDR block for the secondary VPC."
  type        = string
  default     = "10.250.0.0/16"
}

variable "secondary_public_subnet_a_cidr" {
  description = "CIDR block for the secondary VPC's public subnet in AZ a."
  type        = string
  default     = "10.250.10.0/24"
}

variable "secondary_public_subnet_b_cidr" {
  description = "CIDR block for the secondary VPC's public subnet in AZ b."
  type        = string
  default     = "10.250.20.0/24"
}

variable "secondary_private_subnet_a_cidr" {
  description = "CIDR block for the secondary VPC's private subnet in AZ a."
  type        = string
  default     = "10.250.30.0/24"
}

variable "secondary_private_subnet_b_cidr" {
  description = "CIDR block for the secondary VPC's private subnet in AZ b."
  type        = string
  default     = "10.250.40.0/24"
}

# --- Compute Variables ---
variable "instance_type" {
  description = "The EC2 instance type for the test VMs."
  type        = string
}

variable "ssh_key_name" {
  description = "The name of an existing EC2 Key Pair for SSH access."
  type        = string
}

