# /terraform/fortigate.tf

# Data source to find the latest FortiGate AMI
data "aws_ami" "fortigate" {
  most_recent = true
  owners      = ["aws-marketplace"]

  filter {
    name   = "name"
    values = ["FortiGate-VM64-AWS*"]
  }
}

# Security group for the FortiGate instance
resource "aws_security_group" "fortigate_sg" {
  name        = "${var.project_name}-fortigate-sg"
  description = "Allow all traffic to/from the FortiGate"
  vpc_id      = module.vpc["security"].vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.standard_tags, {
    Name = "${var.project_name}-fortigate-sg"
  })
}

# FortiGate instance
resource "aws_instance" "fortigate" {
  ami           = data.aws_ami.fortigate.id
  instance_type = "c5.large" # Recommended size for FortiGate
  subnet_id     = module.vpc["security"].public_subnet_ids[0]
  key_name      = var.ssh_key_name

  vpc_security_group_ids = [aws_security_group.fortigate_sg.id]

  tags = merge(var.standard_tags, {
    Name = "${var.project_name}-fortigate-vm"
  })
}

