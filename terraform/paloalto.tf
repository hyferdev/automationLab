# /terraform/paloalto.tf
# Deploys the Palo Alto Networks VM-Series firewalls and their resources.

# --- IAM Role for Bootstrapping ---
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

# --- Security Group for Data Interface (GWLB Traffic) ---
resource "aws_security_group" "paloalto_data_sg" {
  name        = "${var.project_name}-${var.environment}-paloalto-data-sg"
  description = "Allow GENEVE and Health Checks from GWLB"
  vpc_id      = module.vpc["security"].vpc_id

  # Allow GENEVE Traffic (UDP 6081)
  ingress {
    description = "Allow GENEVE traffic from GWLB"
    from_port   = 6081
    to_port     = 6081
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"] # Open to internal traffic; firewall handles policy
  }

  # Allow Health Checks (TCP 443)
  ingress {
    description = "Allow Health Checks from GWLB"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # GWLB originates from within the VPC
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.standard_tags, var.project_tags, {
    Name = "${var.project_name}-${var.environment}-paloalto-data-sg"
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

# --- Elastic IPs for Data Interfaces ---
resource "aws_eip" "paloalto_data_eip" {
  for_each = toset(var.availability_zones)
  domain   = "vpc"

  tags = merge(var.standard_tags, var.project_tags, {
    Name = "${var.project_name}-${var.environment}-pa-data-eip-${each.key}"
  })
}

# --- Network Interfaces for the Firewalls ---

# Interface 0: Management
resource "aws_network_interface" "paloalto_mgmt" {
  for_each = toset(var.availability_zones)

  subnet_id       = module.vpc["security"].management_subnet_ids_by_az[each.key]
  security_groups = [aws_security_group.paloalto_mgmt_sg.id]
  tags            = { Name = "${var.project_name}-${var.environment}-pa-mgmt-${each.key}" }
}

resource "aws_eip_association" "paloalto_mgmt_eip_assoc" {
  for_each             = toset(var.availability_zones)
  network_interface_id = aws_network_interface.paloalto_mgmt[each.key].id
  allocation_id        = aws_eip.paloalto_mgmt_eip[each.key].id
  depends_on           = [aws_instance.paloalto]
}

# Interface 1: Data (Public Egress) - Maps to ethernet1/1
resource "aws_network_interface" "paloalto_data" {
  for_each = toset(var.availability_zones)
  subnet_id         = module.vpc["security"].egress_subnet_ids_by_az[each.key]
  security_groups   = [aws_security_group.paloalto_data_sg.id]  
  source_dest_check = false
  tags              = { Name = "${var.project_name}-${var.environment}-pa-data-${each.key}" }
}

resource "aws_eip_association" "paloalto_data_eip_assoc" {
  for_each             = toset(var.availability_zones)
  network_interface_id = aws_network_interface.paloalto_data[each.key].id
  allocation_id        = aws_eip.paloalto_data_eip[each.key].id
  depends_on           = [aws_instance.paloalto]
}

# --- Palo Alto VM-Series Instances ---
resource "aws_instance" "paloalto" {
  for_each = toset(var.availability_zones)

  ami                  = data.aws_ami.paloalto.id
  instance_type        = var.paloalto_instance_type
  availability_zone    = each.key
  iam_instance_profile = aws_iam_instance_profile.paloalto_bootstrap_profile.name
  key_name             = var.ssh_key_name

  # Attach the primary (management) interface
  primary_network_interface {
    network_interface_id = aws_network_interface.paloalto_mgmt[each.key].id
  }

  # Use user_data to set the initial admin password
  user_data = "vmseries-bootstrap-aws-s3-bucket=${aws_s3_bucket.bootstrap_bucket.id}"
  user_data_replace_on_change = true

  # Ensure the firewall is recreated if the Data interface is replaced.
  lifecycle {
    replace_triggered_by = [
      aws_network_interface.paloalto_data[each.key]
    ]
  }

  tags = merge(var.standard_tags, var.project_tags, {
    Name = "${var.project_name}-${var.environment}-paloalto-${each.key}"
  })
}

# Attach Data Interface (eth1/1)
resource "aws_network_interface_attachment" "paloalto_attach_data" {
  for_each             = toset(var.availability_zones)
  instance_id          = aws_instance.paloalto[each.key].id
  network_interface_id = aws_network_interface.paloalto_data[each.key].id
  device_index         = 1
}