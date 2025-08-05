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

  vpc_attachments = {
    for key, vpc_module in module.vpc : key => {
      attachment_id = vpc_module.transit_gateway_attachment_id
      cidr_block    = var.vpcs[key].vpc_cidr
    }
  }
}
