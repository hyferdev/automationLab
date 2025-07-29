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

# --- Transit Gateway ---
# Call the Transit Gateway module
module "tgw" {
  source = "./modules/tgw"

  project_name  = var.project_name
  environment   = var.environment
  standard_tags = var.standard_tags
  project_tags  = merge(var.project_tags, { environment = var.environment })

  primary_vpc_attachment_id   = module.vpc.transit_gateway_attachment_id
  secondary_vpc_attachment_id = module.vpc_secondary.transit_gateway_attachment_id
  primary_vpc_cidr            = var.vpc_cidr
  secondary_vpc_cidr          = var.secondary_vpc_cidr
}

# --- VPC ---
# Call the VPC module
module "vpc" {
  source = "./modules/vpc"

  # Pass infrastructure variables
  vpc_cidr              = var.vpc_cidr
  public_subnet_a_cidr  = var.public_subnet_a_cidr
  public_subnet_b_cidr  = var.public_subnet_b_cidr
  private_subnet_a_cidr = var.private_subnet_a_cidr
  private_subnet_b_cidr = var.private_subnet_b_cidr
  availability_zones    = var.availability_zones
  transit_gateway_id    = module.tgw.transit_gateway_id

  # Pass naming and tagging variables
  project_name  = var.project_name
  standard_tags = var.standard_tags
  project_tags  = merge(var.project_tags, { environment = var.environment })
  environment   = var.environment
}

module "vpc_secondary" {
  source = "./modules/vpc"

  vpc_cidr              = var.secondary_vpc_cidr
  public_subnet_a_cidr  = var.secondary_public_subnet_a_cidr
  public_subnet_b_cidr  = var.secondary_public_subnet_b_cidr
  private_subnet_a_cidr = var.secondary_private_subnet_a_cidr
  private_subnet_b_cidr = var.secondary_private_subnet_b_cidr
  availability_zones    = var.availability_zones
  project_name          = "${var.project_name}-secondary" # Give it a distinct name
  environment           = var.environment
  standard_tags         = var.standard_tags
  project_tags          = merge(var.project_tags, { environment = var.environment })
  transit_gateway_id    = module.tgw.transit_gateway_id # Attach to the same TGW
}

# --- Compute ---
# Call the compute module once for each subnet.

module "vm_public_b" {
  source = "./modules/compute"

  instance_name          = "${var.project_name}-${var.environment}-vm-public-b"
  instance_type          = var.instance_type
  vpc_id                 = module.vpc.vpc_id
  subnet_id              = module.vpc.public_subnet_ids[1]
  ssh_key_name           = var.ssh_key_name
  ssh_access_cidr        = var.management_cidr
  internal_traffic_cidrs = var.vpc_cidr
  standard_tags          = var.standard_tags
  project_tags           = merge(var.project_tags, { environment = var.environment })
}

module "vm_private_a" {
  source = "./modules/compute"

  instance_name          = "${var.project_name}-${var.environment}-vm-private-a"
  instance_type          = var.instance_type
  vpc_id                 = module.vpc.vpc_id
  subnet_id              = module.vpc.private_subnet_ids[0]
  ssh_key_name           = var.ssh_key_name
  ssh_access_cidr        = var.management_cidr
  internal_traffic_cidrs = [var.vpc_cidr, var.secondary_vpc_cidr]
  standard_tags          = var.standard_tags
  project_tags           = merge(var.project_tags, { environment = var.environment })
}

module "vm_secondary_private_a" {
  source = "./modules/compute"

  instance_name          = "${var.project_name}-secondary-${var.environment}-vm-private-a"
  instance_type          = var.instance_type
  vpc_id                 = module.vpc_secondary.vpc_id
  subnet_id              = module.vpc_secondary.private_subnet_ids[0]
  ssh_key_name           = var.ssh_key_name
  ssh_access_cidr        = var.management_cidr
  internal_traffic_cidrs = [var.vpc_cidr, var.secondary_vpc_cidr]
  standard_tags          = var.standard_tags
  project_tags           = merge(var.project_tags, { environment = var.environment })
}
