# /terraform/data.tf
# Dynamically finds the correct Palo Alto AMI from the AWS Marketplace.

data "aws_ami" "paloalto" {
  most_recent = true
  owners      = ["679593333241"] # This is the official AWS Account ID for Palo Alto Networks

  filter {
    name   = "name"
    values = ["*f1260463-68e1-4bfb-bf2e-075c2664c1d7*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}