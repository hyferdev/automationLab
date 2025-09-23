# /terraform/fortigate.tf

# This security group allows management access (SSH and HTTPS) from your trusted IP range.
resource "aws_security_group" "fortigate_management_sg" {
  name        = "${var.project_name}-fortigate-management-sg"
  description = "Allow management access to FortiGate instances"
  vpc_id      = module.vpc["security"].vpc_id

/*
  ingress {
    description = "Allow SSH from management CIDR"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.management_cidr]
  }
*/

  ingress {
    description = "Allow HTTPS from management CIDR"
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

  tags = merge(var.standard_tags, var.project_tags, {
    Name = "${var.project_name}-fortigate-management-sg"
  })
}

#Provision Fortigate Public IPs
resource "aws_eip" "fortigate_eip" {
  for_each = toset(var.availability_zones)
  domain   = "vpc"

  tags = merge(var.standard_tags, var.project_tags, {
    Name = "${var.project_name}-fortigate-eip-${each.key}"
  })
}

# Data source to find the latest FortiGate AMI
data "aws_ami" "fortigate" {
  most_recent = true
  owners      = ["aws-marketplace"]

  filter {
    name   = "name"
    values = ["FortiGate-VM64-AWS*"]
  }
}

resource "aws_instance" "fortigate" {
  for_each = toset(var.availability_zones)

  ami           = data.aws_ami.fortigate.id
  instance_type = "c5.large" # Recommended size for FortiGate
  key_name      = var.ssh_key_name
  subnet_id     = module.vpc["security"].appliance_subnet_ids[index(var.availability_zones, each.key)]
  vpc_security_group_ids = [aws_security_group.fortigate_management_sg.id]  
  
  # Disable source/destination check is critical for firewall appliances
  source_dest_check = false

  tags = merge(var.standard_tags, var.project_tags, {
    Name = "${var.project_name}-fortigate-${each.key}"
  })
}

# Associate PIPs with FortiGate Instances 
resource "aws_eip_association" "fortigate_eip_assoc" {
  for_each = aws_instance.fortigate
  instance_id   = each.value.id
  allocation_id = aws_eip.fortigate_eip[each.value.availability_zone].id
}

# Attach each FortiGate instance to the GWLB Target Group
resource "aws_lb_target_group_attachment" "fortigate_attachment" {
  for_each = aws_instance.fortigate

  target_group_arn = aws_lb_target_group.fortigate_tg.arn
  target_id        = each.value.id
}
