#########################
# --- Variables ---
# /terraform/variables.tf
#########################

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
  default     = "dev"
}

# --- Compute Variables ---
variable "instance_type" {
  description = "The EC2 instance type for the test VMs."
  type        = string
  default     = "t2.micro"
}

variable "ssh_key_name" {
  description = "The name of an existing EC2 Key Pair for SSH access."
  type        = string
}

variable "paloalto_ami_id" {
  description = "The AWS Marketplace AMI ID for the Palo Alto Networks VM-Series firewall. If not specified, the latest will be used."
  type        = string
  default     = null # The default is now null
}

variable "paloalto_instance_type" {
  description = "The EC2 instance type for the Palo Alto firewalls."
  type        = string
  default     = "m5.xlarge"
}
