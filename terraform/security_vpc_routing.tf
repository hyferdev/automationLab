# /terraform/security_vpc_routing.tf
# This file contains the routing logic for the security VPC to break the dependency cycle.

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
  # Route to the GWLB endpoint in the same AZ for performance and resilience.
  vpc_endpoint_id        = aws_vpc_endpoint.gwlb_endpoints[each.key].id
}

resource "aws_route_table_association" "private_tgw" {
  for_each = toset(var.availability_zones)

  subnet_id      = module.vpc["security"].private_subnet_ids_by_az[each.key]
  route_table_id = aws_route_table.private_rt_tgw_attachment[each.key].id
}

# Directs all inbound traffic from the internet and from spoke VPCs to the GWLB endpoints.
resource "aws_route_table" "edge_rt" {
  vpc_id = module.vpc["security"].vpc_id
  tags   = merge(var.standard_tags, var.project_tags, { Name = "${var.project_name}-security-edge-rt" })
}

resource "aws_route" "edge_to_gwlb" {
  for_each = toset(concat(values({ for k, v in var.vpcs : k => v.vpc_cidr }), ["0.0.0.0/0"]))

  route_table_id         = aws_route_table.edge_rt.id
  destination_cidr_block = each.value
  # Per AWS best practices for IGW -> GWLB routing, we route to a single endpoint.
  # AWS manages the high availability and failover to endpoints in other AZs behind the scenes.
  vpc_endpoint_id        = values(aws_vpc_endpoint.gwlb_endpoints)[0].id
}

resource "aws_route_table_association" "igw_to_edge" {
  gateway_id     = module.vpc["security"].internet_gateway_id
  route_table_id = aws_route_table.edge_rt.id
}

