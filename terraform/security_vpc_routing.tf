# /terraform/security_vpc_routing.tf
# This file contains the corrected routing logic for the security VPC.

locals {
  # Create a map of all routes needed from the GWLB endpoints back to the TGW.
  # The key is a unique string like "us-east-1a-des", and the value is an object
  # containing the AZ and the destination CIDR.
  gwlb_to_tgw_routes = {
    for tuple in setproduct(var.availability_zones, keys(var.vpcs)) :
    "${tuple[0]}-${tuple[1]}" => {
      az       = tuple[0]
      vpc_cidr = var.vpcs[tuple[1]].vpc_cidr
    } if tuple[1] != "security"
  }
}

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

# Handles traffic AFTER inspection by the FortiGates.
resource "aws_route_table" "gwlb_endpoint_rt" {
  for_each = toset(var.availability_zones)
  vpc_id   = module.vpc["security"].vpc_id
  tags     = merge(var.standard_tags, var.project_tags, { Name = "${var.project_name}-security-gwlb-endpoint-rt-${each.key}" })
}

# Route inspected traffic for spokes back to the TGW.
resource "aws_route" "gwlb_to_tgw" {
  for_each = local.gwlb_to_tgw_routes
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

