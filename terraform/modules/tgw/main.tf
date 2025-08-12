# /terraform/modules/tgw/main.tf
# This module creates an EC2 Transit Gateway.

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

resource "aws_ec2_transit_gateway_route_table" "main" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id

  tags = merge(var.standard_tags, var.project_tags, {
    Name = "${var.project_name}-${var.environment}-tgw-rt"
  })
}

# Associate all VPC attachments with the main TGW route table
resource "aws_ec2_transit_gateway_route_table_association" "vpcs" {
  for_each = var.vpc_attachments

  transit_gateway_attachment_id  = each.value.attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main.id
}

# Create a static route for each VPC in the TGW route table.
# This allows other VPCs to route traffic to this VPC.
resource "aws_ec2_transit_gateway_route" "to_vpcs" {
  for_each = var.vpc_attachments

  destination_cidr_block         = each.value.cidr_block
  transit_gateway_attachment_id  = each.value.attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main.id
}

