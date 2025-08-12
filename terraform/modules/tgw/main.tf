# /terraform/modules/tgw/main.tf
# This module creates an EC2 Transit Gateway with a hub-and-spoke routing architecture.

resource "aws_ec2_transit_gateway" "main" {
  description = "Transit Gateway for the ${var.project_name}-${var.environment} environment"

  # Disable default route table association and propagation to have full control.
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"

  # Enable auto-acceptance of shared attachments if you use AWS RAM
  auto_accept_shared_attachments = "enable"

  tags = merge(var.standard_tags, var.project_tags, {
    Name = "${var.project_name}-${var.environment}-tgw"
  })
}

# --- Route Table for the Security (Hub) VPC ---
resource "aws_ec2_transit_gateway_route_table" "security_rt" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id

  tags = merge(var.standard_tags, var.project_tags, {
    Name = "${var.project_name}-${var.environment}-tgw-security-rt"
  })
}

# --- Route Table for the Spoke VPCs ---
resource "aws_ec2_transit_gateway_route_table" "spoke_rt" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id

  tags = merge(var.standard_tags, var.project_tags, {
    Name = "${var.project_name}-${var.environment}-tgw-spoke-rt"
  })
}

# --- Associate VPCs with the appropriate TGW Route Table ---
resource "aws_ec2_transit_gateway_route_table_association" "vpcs" {
  for_each = var.vpc_attachments

  transit_gateway_attachment_id = each.value.attachment_id
  # Associate the 'security' VPC with the security_rt, and all others with the spoke_rt
  transit_gateway_route_table_id = each.key == "security" ? aws_ec2_transit_gateway_route_table.security_rt.id : aws_ec2_transit_gateway_route_table.spoke_rt.id
}


# --- Define Routes ---

# 1. In the SPOKE route table, create a single default route to the security VPC attachment.
# This forces all traffic from spokes through the firewall.
resource "aws_ec2_transit_gateway_route" "spokes_to_security_hub" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = var.vpc_attachments["security"].attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke_rt.id
}

# 2. In the SECURITY route table, create routes for each spoke VPC's CIDR.
# This allows the firewall to route traffic back to the correct spoke.
resource "aws_ec2_transit_gateway_route" "security_hub_to_spokes" {
  # Only create routes for non-security VPCs
  for_each = {
    for k, v in var.vpc_attachments : k => v if k != "security"
  }

  destination_cidr_block         = each.value.cidr_block
  transit_gateway_attachment_id  = each.value.attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.security_rt.id
}

