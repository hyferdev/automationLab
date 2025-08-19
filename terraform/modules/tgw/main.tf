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

# --- Route Table for Spoke VPCs ---
resource "aws_ec2_transit_gateway_route_table" "spoke_rt" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  tags = merge(var.standard_tags, var.project_tags, { Name = "${var.project_name}-${var.environment}-tgw-spoke-rt" })
}

# --- Associate Spoke VPCs with the Spoke Route Table ---
resource "aws_ec2_transit_gateway_route_table_association" "spokes" {
  for_each = { for k, v in var.vpc_attachments : k => v if k != "security" }

  transit_gateway_attachment_id  = each.value.attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke_rt.id
}

# --- Associate Security VPC with the TGW (it doesn't need a separate table) ---
resource "aws_ec2_transit_gateway_route_table_association" "security" {
  # Assuming 'security' VPC attachment exists in var.vpc_attachments
  transit_gateway_attachment_id  = var.vpc_attachments["security"].attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.main.association_default_route_table_id
}

# --- Default Route for Spokes ---
# In the spoke route table, send ALL traffic to the security VPC attachment.
resource "aws_ec2_transit_gateway_route" "spokes_to_security" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = var.vpc_attachments["security"].attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke_rt.id
}
