#################################
# --- VPC ---
# Call the VPC module
#################################
module "vpc" {
  source = "./modules/vpc"

  # Pass infrastructure variables
  vpc_cidr              = var.vpc_cidr
  public_subnet_a_cidr  = var.public_subnet_a_cidr
  public_subnet_b_cidr  = var.public_subnet_b_cidr
  private_subnet_a_cidr = var.private_subnet_a_cidr
  private_subnet_b_cidr = var.private_subnet_b_cidr
  availability_zones    = var.availability_zones
  transit_gateway_id    = module.tgw.transit_gateway_id

  # Pass naming and tagging variables
  project_name  = var.project_name
  standard_tags = var.standard_tags
  project_tags  = merge(var.project_tags, { environment = var.environment })
  environment   = var.environment
}

module "vpc_secondary" {
  source = "./modules/vpc"

  vpc_cidr              = var.secondary_vpc_cidr
  public_subnet_a_cidr  = var.secondary_public_subnet_a_cidr
  public_subnet_b_cidr  = var.secondary_public_subnet_b_cidr
  private_subnet_a_cidr = var.secondary_private_subnet_a_cidr
  private_subnet_b_cidr = var.secondary_private_subnet_b_cidr
  availability_zones    = var.availability_zones
  project_name          = "${var.project_name}-secondary" # Give it a distinct name
  environment           = var.environment
  standard_tags         = var.standard_tags
  project_tags          = merge(var.project_tags, { environment = var.environment })
  transit_gateway_id    = module.tgw.transit_gateway_id # Attach to the same TGW
}

