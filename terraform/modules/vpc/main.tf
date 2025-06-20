# /terraform/modules/vpc/main.tf
# This file contains the core logic of the VPC module.

# --- VPC Definition ---
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.standard_tags, var.project_tags, {
    Name = "${var.project_name}-${var.environment}-vpc"
  })
}

# --- Subnets ---
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_a_cidr
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = true

  tags = merge(var.standard_tags, var.project_tags, {
    Name = "${var.project_name}-${var.environment}-public-subnet-a"
  })
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_b_cidr
  availability_zone       = var.availability_zones[1]
  map_public_ip_on_launch = true

  tags = merge(var.standard_tags, var.project_tags, {
    Name = "${var.project_name}-${var.environment}-public-subnet-b"
  })
}

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_a_cidr
  availability_zone = var.availability_zones[0]

  tags = merge(var.standard_tags, var.project_tags, {
    Name = "${var.project_name}-${var.environment}-private-subnet-a"
  })
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_b_cidr
  availability_zone = var.availability_zones[1]

  tags = merge(var.standard_tags, var.project_tags, {
    Name = "${var.project_name}-${var.environment}-private-subnet-b"
  })
}

# --- Internet Gateway (for Public Subnets) ---
resource "aws_internet_gateway" "main_gw" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.standard_tags, var.project_tags, {
    Name = "${var.project_name}-${var.environment}-igw"
  })
}

# --- Public Route Table ---
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_gw.id
  }

  tags = merge(var.standard_tags, var.project_tags, {
    Name = "${var.project_name}-${var.environment}-public-rt"
  })
}

# --- Route Table Associations ---
resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public_rt.id
}
