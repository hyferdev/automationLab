#########################
# --- Providers ---
# /terraform/providers.tf
#########################

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

