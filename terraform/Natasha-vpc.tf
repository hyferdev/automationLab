#################################
# --- VPC ---
# Call the VPC module
#################################
module "Natasha-vpc" {
  source = "./modules/vpc"

  # Pass infrastructure variables
  vpc_cidr              = var.natasha_vpc_cidr
  public_subnet_a_cidr  = var.natasha_public_subnet_a_cidr
  public_subnet_b_cidr  = var.natasha_public_subnet_b_cidr
  private_subnet_a_cidr = var.natasha_private_subnet_a_cidr
  private_subnet_b_cidr = var.natasha_private_subnet_b_cidr
  availability_zones    = var.availability_zones
  transit_gateway_id    = module.tgw.transit_gateway_id

  # Pass naming and tagging variables
  project_name  = var.project_name
  standard_tags = var.standard_tags
  project_tags  = merge(var.project_tags, { environment = var.environment })
  environment   = var.environment
}
