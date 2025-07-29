# /terraform/modules/tgw/main.tf
# This module creates an EC2 Transit Gateway.

resource "aws_ec2_transit_gateway" "main" {
  description = "Transit Gateway for the ${var.project_name}-${var.environment} environment"
  
  # Disable default route table association and propagation to have full control.
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"

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

resource "aws_ec2_transit_gateway_route_table_association" "primary" {
  transit_gateway_attachment_id  = var.primary_vpc_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main.id
}

resource "aws_ec2_transit_gateway_route_table_association" "secondary" {
  transit_gateway_attachment_id  = var.secondary_vpc_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main.id
}

resource "aws_ec2_transit_gateway_route" "to_primary" {
  destination_cidr_block         = var.primary_vpc_cidr
  transit_gateway_attachment_id  = var.primary_vpc_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main.id
}

resource "aws_ec2_transit_gateway_route" "to_secondary" {
  destination_cidr_block         = var.secondary_vpc_cidr
  transit_gateway_attachment_id  = var.secondary_vpc_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main.id
}
