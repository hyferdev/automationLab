# /terraform/main.tf
# This is the root configuration that calls modules.
     
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  cloud {
  }
}

provider "aws" {
  region = var.aws_region
}

# --- VPC ---
# Call the VPC module
module "vpc" {
  source = "./modules/vpc"

  # Pass infrastructure variables
  vpc_cidr               = var.vpc_cidr
  public_subnet_a_cidr   = var.public_subnet_a_cidr
  public_subnet_b_cidr   = var.public_subnet_b_cidr
  private_subnet_a_cidr  = var.private_subnet_a_cidr
  private_subnet_b_cidr  = var.private_subnet_b_cidr
  availability_zones     = var.availability_zones

  # Pass naming and tagging variables
  project_name           = var.project_name
  standard_tags          = var.standard_tags
  project_tags           = merge(var.project_tags, { environment = var.environment })
  environment            = var.environment
}

# --- Compute ---
# Call the compute module once for each subnet.

module "vm_public_a" {
  source = "./modules/compute"

  instance_name         = "${var.project_name}-${var.environment}-vm-public-a"
  instance_type         = var.instance_type
  vpc_id                = module.vpc.vpc_id
  subnet_id             = module.vpc.public_subnet_ids[0]
  ssh_key_name          = var.ssh_key_name
  ssh_access_cidr       = var.management_cidr
  internal_traffic_cidr = var.vpc_cidr
  standard_tags         = var.standard_tags
  project_tags          = merge(var.project_tags, { environment = var.environment })
}

/*
module "vm_public_b" {
  source = "./modules/compute"

  instance_name         = "${var.project_name}-${var.environment}-vm-public-b"
  instance_type         = var.instance_type
  vpc_id                = module.vpc.vpc_id
  subnet_id             = module.vpc.public_subnet_ids[1]
  ssh_key_name          = var.ssh_key_name
  ssh_access_cidr       = var.management_cidr
  internal_traffic_cidr = var.vpc_cidr
  standard_tags         = var.standard_tags
  project_tags          = merge(var.project_tags, { environment = var.environment })
}
*/

module "vm_private_a1" {
  source = "./modules/compute"

  instance_name         = "${var.project_name}-${var.environment}-vm-private-a1"
  instance_type         = var.instance_type
  vpc_id                = module.vpc.vpc_id
  subnet_id             = module.vpc.private_subnet_ids[0]
  ssh_key_name          = var.ssh_key_name
  ssh_access_cidr       = var.management_cidr
  internal_traffic_cidr = var.vpc_cidr
  standard_tags         = var.standard_tags
  project_tags          = merge(var.project_tags, { environment = var.environment })
}

module "vm_private_a2" {
  source = "./modules/compute"

  instance_name         = "${var.project_name}-${var.environment}-vm-private-a2"
  instance_type         = var.instance_type
  vpc_id                = module.vpc.vpc_id
  subnet_id             = module.vpc.private_subnet_ids[0]
  ssh_key_name          = var.ssh_key_name
  ssh_access_cidr       = var.management_cidr
  internal_traffic_cidr = var.vpc_cidr
  standard_tags         = var.standard_tags
  project_tags          = merge(var.project_tags, { environment = var.environment })
}

/*
module "vm_private_b" {
  source = "./modules/compute"

  instance_name         = "${var.project_name}-${var.environment}-vm-private-b"
  instance_type         = var.instance_type
  vpc_id                = module.vpc.vpc_id
  subnet_id             = module.vpc.private_subnet_ids[1]
  ssh_key_name          = var.ssh_key_name
  ssh_access_cidr       = var.management_cidr
  internal_traffic_cidr = var.vpc_cidr
  standard_tags         = var.standard_tags
  project_tags          = merge(var.project_tags, { environment = var.environment })
}
*/
