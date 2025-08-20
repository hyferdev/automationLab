# /terraform/security_vpc_routing.tf
# This file contains the corrected routing logic for the security VPC.

# --- ROUTING FOR SECURITY VPC ---
# All traffic entering from the TGW is sent to the GWLB endpoints.
resource "aws_route_table" "private_rt_tgw_attachment" {
  for_each = toset(var.availability_zones)
  vpc_id   = module.vpc["security"].vpc_id
  tags     = merge(var.standard_tags, var.project_tags, { Name = "${var.project_name}-security-private-rt-tgw-${each.key}" })
}

resource "aws_route" "private_to_gwlb" {
  for_each = toset(var.availability_zones)
  route_table_id         = aws_route_table.private_rt_tgw_attachment[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = aws_vpc_endpoint.gwlb_endpoints[each.key].id
}

resource "aws_route_table_association" "private_tgw" {
  for_each = toset(var.availability_zones)
  subnet_id      = module.vpc["security"].private_subnet_ids_by_az[each.key]
  route_table_id = aws_route_table.private_rt_tgw_attachment[each.key].id
}

# Associated with the IGW. Intercepts traffic from the internet to spokes and sends it to the GWLB.
resource "aws_route_table" "edge_rt" {
  vpc_id = module.vpc["security"].vpc_id
  tags   = merge(var.standard_tags, var.project_tags, { Name = "${var.project_name}-security-edge-rt" })
}

resource "aws_route" "ingress_to_gwlb" {
  # Create a route for each SPOKE VPC's CIDR. This is the only valid target from an IGW to an endpoint.
  for_each = { for k, v in var.vpcs : k => v.vpc_cidr if k != "security" }
  route_table_id         = aws_route_table.edge_rt.id
  destination_cidr_block = each.value
  vpc_endpoint_id        = values(aws_vpc_endpoint.gwlb_endpoints)[0].id
}

resource "aws_route_table_association" "igw_to_edge" {
  gateway_id     = module.vpc["security"].internet_gateway_id
  route_table_id = aws_route_table.edge_rt.id
}

# Handles traffic AFTER inspection by the FortiGates.
resource "aws_route_table" "gwlb_endpoint_rt" {
  for_each = toset(var.availability_zones)
  vpc_id   = module.vpc["security"].vpc_id
  tags     = merge(var.standard_tags, var.project_tags, { Name = "${var.project_name}-security-gwlb-endpoint-rt-${each.key}" })
}

# Route inspected traffic for spokes back to the TGW.
resource "aws_route" "gwlb_to_tgw" {
  for_each = {
    for az in var.availability_zones :
    for vpc_key, vpc_details in var.vpcs :
    "${az}-${vpc_key}" => {
      az         = az
      vpc_cidr   = vpc_details.vpc_cidr
      is_security = vpc_key == "security"
    } if !is_security
  }
  route_table_id         = aws_route_table.gwlb_endpoint_rt[each.value.az].id
  destination_cidr_block = each.value.vpc_cidr
  transit_gateway_id     = module.tgw.transit_gateway_id
}

# Route inspected internet-bound traffic to the IGW.
resource "aws_route" "gwlb_to_igw" {
  for_each = toset(var.availability_zones)
  route_table_id         = aws_route_table.gwlb_endpoint_rt[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = module.vpc["security"].internet_gateway_id
}

resource "aws_route_table_association" "gwlb_endpoint_subnets" {
  for_each = toset(var.availability_zones)
  subnet_id      = module.vpc["security"].gwlb_endpoint_subnet_ids_by_az[each.key]
  route_table_id = aws_route_table.gwlb_endpoint_rt[each.key].id
}

