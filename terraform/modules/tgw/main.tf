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

# Create routes for inter-VPC communication
# This logic creates a full mesh: a route from every VPC to every other VPC.
resource "aws_ec2_transit_gateway_route" "to_vpcs" {
  # Create a flattened list of all possible route combinations
  for_each = {
    for from_key, from_vpc in var.vpc_attachments :
    for to_key, to_vpc in var.vpc_attachments :
    # Only create a route if the source and destination are different
    if from_key != to_key :
    "${from_key}-to-${to_key}" => {
      from_attachment_id = from_vpc.attachment_id
      to_cidr_block      = to_vpc.cidr_block
      # This is the attachment that traffic will be routed *through* to reach the destination
      route_attachment_id = to_vpc.attachment_id
    }
  }

  destination_cidr_block         = each.value.to_cidr_block
  transit_gateway_attachment_id  = each.value.route_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main.id
}

