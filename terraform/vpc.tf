#################################
# --- VPC ---
# Call the VPC module
#################################
module "vpc" {
  for_each = var.vpcs
  source   = "./modules/vpc"

  vpc_cidr               = each.value.vpc_cidr
  public_subnet_a_cidr   = each.value.public_subnet_a_cidr
  public_subnet_b_cidr   = each.value.public_subnet_b_cidr
  private_subnet_a_cidr  = each.value.private_subnet_a_cidr
  private_subnet_b_cidr  = each.value.private_subnet_b_cidr
  
  availability_zones     = var.availability_zones
  project_name           = "${var.project_name}-${each.key}"
  environment            = var.environment
  standard_tags          = var.standard_tags
  project_tags           = merge(var.project_tags, { environment = var.environment })
  transit_gateway_id     = module.tgw.transit_gateway_id
}

/*
module "vpc_secondary" {
  source = "./modules/vpc"

  vpc_cidr              = var.secondary_vpc_cidr
  public_subnet_a_cidr  = var.secondary_public_subnet_a_cidr
  public_subnet_b_cidr  = var.secondary_public_subnet_b_cidr
  private_subnet_a_cidr = var.secondary_private_subnet_a_cidr
  private_subnet_b_cidr = var.secondary_private_subnet_b_cidr
  availability_zones    = var.availability_zones
  project_name          = "${var.project_name}-secondary"
  environment           = var.environment
  standard_tags         = var.standard_tags
  project_tags          = merge(var.project_tags, { environment = var.environment })
  transit_gateway_id    = module.tgw.transit_gateway_id
}
*/
