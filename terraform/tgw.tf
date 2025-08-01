#################################
# --- Transit Gateway ---
# Call the Transit Gateway module
#################################
module "tgw" {
  source = "./modules/tgw"

  project_name  = var.project_name
  environment   = var.environment
  standard_tags = var.standard_tags
  project_tags  = merge(var.project_tags, { environment = var.environment })

  primary_vpc_attachment_id   = module.vpc.transit_gateway_attachment_id
  secondary_vpc_attachment_id = module.vpc_secondary.transit_gateway_attachment_id
  primary_vpc_cidr            = var.vpc_cidr
  secondary_vpc_cidr          = var.secondary_vpc_cidr
}
