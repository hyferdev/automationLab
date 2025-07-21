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

# --- VPC ---

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
  environment            = var.environment
}

# --- Security Groups ---
resource "aws_security_group" "bastion_sg" {
  name        = "${var.project_name}-${var.environment}-bastion-sg"
  description = "Controls access to the public bastion host"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Allow SSH from trusted management network"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.management_cidr]
  }

  ingress {
    description = "Allow Ping from trusted management network"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.management_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.standard_tags, var.project_tags, {
    Name = "${var.project_name}-${var.environment}-bastion-sg"
  })
}

resource "aws_security_group" "private_sg" {
  name        = "${var.project_name}-${var.environment}-private-sg"
  description = "Controls access to private servers"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "Allow SSH from the bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  ingress {
    description     = "Allow Ping from the bastion"
    from_port       = -1
    to_port         = -1
    protocol        = "icmp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  ingress {
    description = "Allow all traffic between instances in this group"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.standard_tags, var.project_tags, {
    Name = "${var.project_name}-${var.environment}-private-sg"
  })
}

# --- Compute ---

module "vm_public_a" {
  source = "./modules/compute"

  instance_name          = "${var.project_name}-${var.environment}-vm-public-a"
  instance_os            = var.instance_os
  instance_type          = var.instance_type
  instance_disk_size     = var.instance_disk_size
  vpc_id                 = module.vpc.vpc_id
  subnet_id              = module.vpc.public_subnet_ids[0]
  ssh_key_name           = var.ssh_key_name
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  standard_tags          = var.standard_tags
  project_tags           = merge(var.project_tags, { environment = var.environment })
}

module "vm_private_a1" {
  source = "./modules/compute"

  instance_name          = "${var.project_name}-${var.environment}-vm-private-a1"
  instance_os            = var.instance_os
  instance_type          = var.instance_type
  instance_disk_size     = var.instance_disk_size
  vpc_id                 = module.vpc.vpc_id
  subnet_id              = module.vpc.private_subnet_ids[0]
  private_ip             = "10.20.60.201"
  ssh_key_name           = var.ssh_key_name
  vpc_security_group_ids = [aws_security_group.private_sg.id]
  standard_tags          = var.standard_tags
  project_tags           = merge(var.project_tags, { environment = var.environment })
}

module "vm_private_a2" {
  source = "./modules/compute"

  instance_name          = "${var.project_name}-${var.environment}-vm-private-a2"
  instance_os            = var.instance_os
  instance_type          = var.instance_type
  instance_disk_size     = var.instance_disk_size
  vpc_id                 = module.vpc.vpc_id
  subnet_id              = module.vpc.private_subnet_ids[0]
  private_ip             = "10.20.60.202"
  ssh_key_name           = var.ssh_key_name
  vpc_security_group_ids = [aws_security_group.private_sg.id]
  standard_tags          = var.standard_tags
  project_tags           = merge(var.project_tags, { environment = var.environment })
}
