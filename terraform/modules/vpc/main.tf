# /terraform/modules/vpc/main.tf
# This file contains the core logic of the VPC module, including GWLB routing.

# --- VPC Definition ---
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.standard_tags, var.project_tags, {
    Name = "${var.project_name}-${var.environment}-vpc"
  })
}

# --- Local values for mapping resources to AZs ---
locals {
  private_subnets_by_az = {
    "${var.availability_zones[0]}" = aws_subnet.private_a.id,
    "${var.availability_zones[1]}" = aws_subnet.private_b.id
  }
}

# --- Standard Subnets ---
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_a_cidr
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = true
  tags = merge(var.standard_tags, var.project_tags, { Name = "${var.project_name}-${var.environment}-public-subnet-a" })
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_b_cidr
  availability_zone       = var.availability_zones[1]
  map_public_ip_on_launch = true
  tags = merge(var.standard_tags, var.project_tags, { Name = "${var.project_name}-${var.environment}-public-subnet-b" })
}

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_a_cidr
  availability_zone = var.availability_zones[0]
  tags = merge(var.standard_tags, var.project_tags, { Name = "${var.project_name}-${var.environment}-private-subnet-a" })
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_b_cidr
  availability_zone = var.availability_zones[1]
  tags = merge(var.standard_tags, var.project_tags, { Name = "${var.project_name}-${var.environment}-private-subnet-b" })
}

# --- Gateways ---
resource "aws_internet_gateway" "main_gw" {
  vpc_id = aws_vpc.main.id
  tags = merge(var.standard_tags, var.project_tags, { Name = "${var.project_name}-${var.environment}-igw" })
}

# --- Appliance Subnets (for FortiGates) ---
resource "aws_subnet" "appliance_a" {
  count = var.appliance_subnet_a_cidr != null ? 1 : 0
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.appliance_subnet_a_cidr
  availability_zone = var.availability_zones[0]
  tags = merge(var.standard_tags, var.project_tags, { Name = "${var.project_name}-${var.environment}-appliance-subnet-a" })
}
resource "aws_subnet" "appliance_b" {
  count = var.appliance_subnet_b_cidr != null ? 1 : 0
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.appliance_subnet_b_cidr
  availability_zone = var.availability_zones[1]
  tags = merge(var.standard_tags, var.project_tags, { Name = "${var.project_name}-${var.environment}-appliance-subnet-b" })
}

# --- GWLB Endpoint Subnets ---
resource "aws_subnet" "gwlb_endpoint_a" {
  count = var.gwlb_endpoint_subnet_a_cidr != null ? 1 : 0
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.gwlb_endpoint_subnet_a_cidr
  availability_zone = var.availability_zones[0]
  tags = merge(var.standard_tags, var.project_tags, { Name = "${var.project_name}-${var.environment}-gwlb-endpoint-subnet-a" })
}

resource "aws_subnet" "gwlb_endpoint_b" {
  count = var.gwlb_endpoint_subnet_b_cidr != null ? 1 : 0
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.gwlb_endpoint_subnet_b_cidr
  availability_zone = var.availability_zones[1]
  tags = merge(var.standard_tags, var.project_tags, { Name = "${var.project_name}-${var.environment}-gwlb-endpoint-subnet-b" })
}

# --- ROUTING ---
# Spoke VPC Routing
resource "aws_route_table" "public_rt_spoke" {
  count  = var.appliance_subnet_a_cidr == null ? 1 : 0
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_gw.id
  }

  tags = merge(var.standard_tags, var.project_tags, {
    Name = "${var.project_name}-${var.environment}-public-rt"
  })
}

resource "aws_route_table_association" "public_a_spoke" {
  count          = var.appliance_subnet_a_cidr == null ? 1 : 0
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_rt_spoke[0].id
}

resource "aws_route_table_association" "public_b_spoke" {
  count          = var.appliance_subnet_a_cidr == null ? 1 : 0
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public_rt_spoke[0].id
}

# Security Appliance Routing
resource "aws_route_table" "appliance_rt" {
  count  = var.appliance_subnet_a_cidr != null ? 1 : 0
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_gw.id
  }
  tags = merge(var.standard_tags, var.project_tags, { Name = "${var.project_name}-${var.environment}-appliance-rt" })
}

resource "aws_route_table_association" "appliance_a" {
  count          = var.appliance_subnet_a_cidr != null ? 1 : 0
  subnet_id      = aws_subnet.appliance_a[0].id
  route_table_id = aws_route_table.appliance_rt[0].id
}

resource "aws_route_table_association" "appliance_b" {
  count          = var.appliance_subnet_b_cidr != null ? 1 : 0
  subnet_id      = aws_subnet.appliance_b[0].id
  route_table_id = aws_route_table.appliance_rt[0].id
}

resource "aws_route_table" "private_rt_spoke" {
  # Only create this for spoke VPCs (i.e., those without appliance subnets)
  count  = var.appliance_subnet_a_cidr == null ? 1 : 0
  vpc_id = aws_vpc.main.id
  route {
    cidr_block         = "0.0.0.0/0"
    transit_gateway_id = var.transit_gateway_id
  }
  tags = merge(var.standard_tags, var.project_tags, { Name = "${var.project_name}-${var.environment}-private-rt" })
}

resource "aws_route_table_association" "private_a_spoke" {
  count          = var.appliance_subnet_a_cidr == null ? 1 : 0
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_rt_spoke[0].id
}

resource "aws_route_table_association" "private_b_spoke" {
  count          = var.appliance_subnet_a_cidr == null ? 1 : 0
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private_rt_spoke[0].id
}

# --- TGW Attachment ---
resource "aws_ec2_transit_gateway_vpc_attachment" "main" {
  subnet_ids         = [aws_subnet.private_a.id, aws_subnet.private_b.id]
  transit_gateway_id = var.transit_gateway_id
  vpc_id             = aws_vpc.main.id
  tags = merge(var.standard_tags, var.project_tags, { Name = "${var.project_name}-${var.environment}-tgw-attachment" })
}

