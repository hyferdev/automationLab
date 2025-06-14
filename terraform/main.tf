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

module "vpc" {
  source = "./modules/vpc"

  vpc_cidr               = var.vpc_cidr
  public_subnet_a_cidr   = var.public_subnet_a_cidr
  public_subnet_b_cidr   = var.public_subnet_b_cidr
  private_subnet_a_cidr  = var.private_subnet_a_cidr
  private_subnet_b_cidr  = var.private_subnet_b_cidr
  availability_zones     = var.availability_zones
  project_name           = var.project_name
  standard_tags          = var.standard_tags
  project_tags           = merge(var.project_tags, { environment = var.environment })
}

