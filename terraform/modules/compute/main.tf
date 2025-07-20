# /terraform/modules/compute/main.tf
# This module deploys a single EC2 instance.

# This data source looks up the latest Ubuntu 22.04 LTS AMI in the current region.

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
/*
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
*/
# This security group allows SSH access from a specified IP range.
resource "aws_security_group" "instance_sg" {
  name        = "${var.instance_name}-sg"
  description = "Allow SSH, ICMP, and internal traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from trusted source"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_access_cidr]
  }

  ingress {
    description = "Allow ICMP (ping) from trusted source"
    from_port   = -1 # -1 means all ICMP types
    to_port     = -1 # -1 means all ICMP codes
    protocol    = "icmp"
    cidr_blocks = [var.ssh_access_cidr]
  }

  ingress {
    description = "Allow all internal VPC traffic"
    from_port   = 0    # 0 means all ports
    to_port     = 0    # 0 means all ports
    protocol    = "-1" # -1 means all protocols
    cidr_blocks = [var.internal_traffic_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.standard_tags, var.project_tags, {
    Name = "${var.instance_name}-sg"
  })
}

# The EC2 instance resource.
resource "aws_instance" "vm" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  key_name               = var.ssh_key_name
  vpc_security_group_ids = [aws_security_group.instance_sg.id]

  tags = merge(var.standard_tags, var.project_tags, {
    Name = var.instance_name
  })
}
