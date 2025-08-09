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
  default     = "dev"
}

# --- Network CIDR Variables ---
variable "vpcs" {
  description = "A map of VPC configurations. The key of each item is the logical name of the VPC (e.g., 'primary', 'secondary')."
  type = map(object({
    vpc_cidr               = string
    public_subnet_a_cidr   = string
    public_subnet_b_cidr   = string
    private_subnet_a_cidr  = string
    private_subnet_b_cidr  = string
  }))
  default = {
    primary = {
      vpc_cidr               = "10.100.0.0/16"
      public_subnet_a_cidr   = "10.100.10.0/24"
      public_subnet_b_cidr   = "10.100.20.0/24"
      private_subnet_a_cidr  = "10.100.30.0/24"
      private_subnet_b_cidr  = "10.100.40.0/24"
    },
    secondary = {
      vpc_cidr               = "10.250.0.0/16"
      public_subnet_a_cidr   = "10.250.10.0/24"
      public_subnet_b_cidr   = "10.250.20.0/24"
      private_subnet_a_cidr  = "10.250.30.0/24"
      private_subnet_b_cidr  = "10.250.40.0/24"
    }
    natasha = {
      vpc_cidr               = "10.15.0.0/16"
      public_subnet_a_cidr   = "10.15.10.0/24"
      public_subnet_b_cidr   = "10.15.20.0/24"
      private_subnet_a_cidr  = "10.15.30.0/24"
      private_subnet_b_cidr  = "10.15.40.0/24"
    }
    fre = {
      vpc_cidr               = "10.150.0.0/16"
      public_subnet_a_cidr   = "10.150.14.0/24"
      public_subnet_b_cidr   = "10.150.24.0/24"
      private_subnet_a_cidr  = "10.150.34.0/24"
      private_subnet_b_cidr  = "10.150.44.0/24"
    }
  }
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

