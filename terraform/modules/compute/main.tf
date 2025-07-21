V# /terraform/modules/compute/main.tf
# This module deploys a single EC2 instance.

data "aws_ami" "debian" {
  most_recent = true
  filter {
    name   = "name"
    values = ["debian-12-amd64-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["136693071363"] # Debian's official AWS account ID
}

data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical's AWS account ID
}

resource "aws_instance" "vm" {
  ami                      = var.instance_os == "debian" ? data.aws_ami.debian.id : data.aws_ami.ubuntu.id
  instance_type            = var.instance_type
  subnet_id                = var.subnet_id
  key_name                 = var.ssh_key_name
  vpc_security_group_ids   = var.vpc_security_group_ids
  private_ip               = var.private_ip

  root_block_device {
    volume_size = var.instance_disk_size
  }

  tags = merge(var.standard_tags, var.project_tags, {
    Name = var.instance_name
  })
}
