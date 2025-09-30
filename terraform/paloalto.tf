# /terraform/paloalto.tf
# Deploys the Palo Alto Networks VM-Series firewalls and their resources.

# --- IAM Role for Bootstrapping ---
# This role allows the firewall instance to read its configuration from an S3 bucket.
resource "aws_iam_role" "paloalto_bootstrap_role" {
  name = "${var.project_name}-${var.environment}-paloalto-bootstrap-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "paloalto_bootstrap_policy" {
  name = "${var.project_name}-${var.environment}-paloalto-bootstrap-policy"
  role = aws_iam_role.paloalto_bootstrap_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action   = ["s3:GetObject"],
      Effect   = "Allow",
      Resource = "${aws_s3_bucket.bootstrap_bucket.arn}/*"
    }]
  })
}

resource "aws_iam_instance_profile" "paloalto_bootstrap_profile" {
  name = "${var.project_name}-${var.environment}-paloalto-bootstrap-profile"
  role = aws_iam_role.paloalto_bootstrap_role.name
}

# --- Security Group for Management Access ---
resource "aws_security_group" "paloalto_mgmt_sg" {
  name        = "${var.project_name}-${var.environment}-paloalto-mgmt-sg"
  description = "Allow management access (SSH/HTTPS) to Palo Alto firewalls"
  vpc_id      = module.vpc["security"].vpc_id

  ingress {
    description = "Allow HTTPS from management CIDR"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.management_cidr]
  }

  ingress {
    description = "Allow SSH from management CIDR"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.management_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.standard_tags, var.project_tags, {
    Name = "${var.project_name}-${var.environment}-paloalto-mgmt-sg"
  })
}

# --- Elastic IPs for Management Interfaces ---
resource "aws_eip" "paloalto_mgmt_eip" {
  for_each = toset(var.availability_zones)
  domain   = "vpc"

  tags = merge(var.standard_tags, var.project_tags, {
    Name = "${var.project_name}-${var.environment}-pa-mgmt-eip-${each.key}"
  })
}

# --- Network Interfaces for the Firewalls ---
resource "aws_network_interface" "paloalto_interfaces" {
  for_each = toset(var.availability_zones)

  # Interface 0: Management
  # Attached to the management subnet.
  subnet_id       = module.vpc["security"].management_subnet_ids_by_az[each.key]
  security_groups = [aws_security_group.paloalto_mgmt_sg.id]
  tags            = { Name = "${var.project_name}-${var.environment}-pa-mgmt-${each.key}" }
}

resource "aws_eip_association" "paloalto_mgmt_eip_assoc" {
  for_each             = toset(var.availability_zones)
  network_interface_id = aws_network_interface.paloalto_interfaces[each.key].id
  allocation_id        = aws_eip.paloalto_mgmt_eip[each.key].id
}

resource "aws_network_interface" "paloalto_interfaces_egress" {
  for_each = toset(var.availability_zones)

  # Interface 1: Egress (to Internet)
  # Attached to the public egress subnet. Source/Dest check MUST be disabled.
  subnet_id         = module.vpc["security"].egress_subnet_ids_by_az[each.key]
  source_dest_check = false
  tags              = { Name = "${var.project_name}-${var.environment}-pa-egress-${each.key}" }
}

resource "aws_network_interface" "paloalto_interfaces_tgw" {
  for_each = toset(var.availability_zones)

  # Interface 2: TGW/GENEVE (to GWLB and TGW)
  # Attached to the private TGW subnet. Source/Dest check MUST be disabled.
  subnet_id         = module.vpc["security"].private_subnet_ids_by_az[each.key]
  source_dest_check = false
  tags              = { Name = "${var.project_name}-${var.environment}-pa-tgw-${each.key}" }

}

# --- Palo Alto VM-Series Instances ---
resource "aws_instance" "paloalto" {
  for_each = toset(var.availability_zones)

  ami               = data.aws_ami.paloalto.id
  instance_type     = var.paloalto_instance_type
  availability_zone = each.key
  iam_instance_profile = aws_iam_instance_profile.paloalto_bootstrap_profile.name
  key_name          = var.ssh_key_name

  # Attach the interfaces in the correct order.
  network_interface {
    network_interface_id = aws_network_interface.paloalto_interfaces[each.key].id
    device_index         = 0
  }
  network_interface {
    network_interface_id = aws_network_interface.paloalto_interfaces_egress[each.key].id
    device_index         = 1
  }
  network_interface {
    network_interface_id = aws_network_interface.paloalto_interfaces_tgw[each.key].id
    device_index         = 2
  }
/*
  # User data triggers the bootstrap process.
  user_data = <<-EOT
    plugin-op-commands=aws-vmseries-bootstrap-get-config:
    mgmt-interface-swap=enable
  EOT
*/
  tags = merge(var.standard_tags, var.project_tags, {
    Name = "${var.project_name}-${var.environment}-paloalto-${each.key}"
  })
}

