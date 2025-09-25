# /terraform/data.tf
# This file contains data sources to look up dynamic information.

data "aws_ami" "paloalto" {
  most_recent = true
  owners      = ["679593333241"] # Official AWS Account ID for Palo Alto Networks

  filter {
    name = "name"
    values = ["PA-VM-AWS-11.1.*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}