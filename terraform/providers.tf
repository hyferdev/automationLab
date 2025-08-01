# /terraform/main.tf
# This is the root configuration that calls modules.

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  #  cloud {
  #  }
}

provider "aws" {
  region = var.aws_region
}

