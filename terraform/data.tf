# /terraform/data.tf
# This file contains data sources to look up dynamic information.

data "aws_ami" "paloalto" {
  most_recent = true
  owners      = ["679593333241"] # This is the official AWS Account ID for Palo Alto Networks

  filter {
    name   = "name"
    # This filter targets the VM-Series, Bundle 2, PAYG model.
    # The version numbers are wildcarded to grab the latest.
    values = ["PA-VM-AWS-11.1.*-b2-payg-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "product-code"
    # This is the specific product code for "VM-Series Next-Generation Firewall Bundle 2"
    # You can find this on the AWS Marketplace page for the product.
    values = ["6kxdw3bbmdeda5ws5i69op56b"]
  }
}
