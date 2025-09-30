# /terraform/providers.tf
# Declares all Terraform providers used in this project.

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    panos = {
      source = "PaloAltoNetworks/panos"
      version = "~> 2.0.0"
    }
  }
  cloud {
  }
}

provider "aws" {
  region = var.aws_region
}

