################################################
# --- Compute ---
# Call the compute module once for each VPC.
# This creates one public and one private VM per VPC.
###############################################

# Flatten the VPC data to make it easier to loop through subnets
locals {
  vm_deployments = flatten([
    for vpc_key, vpc_details in module.vpc : [
      {
        vpc_key       = vpc_key
        vpc_id        = vpc_details.vpc_id
        subnet_id     = vpc_details.public_subnet_ids[0]
        instance_tier = "public"
        instance_name = "${var.project_name}-${vpc_key}-${var.environment}-vm-public-a"
      },
      {
        vpc_key       = vpc_key
        vpc_id        = vpc_details.vpc_id
        subnet_id     = vpc_details.private_subnet_ids[1]
        instance_tier = "private"
        instance_name = "${var.project_name}-${vpc_key}-${var.environment}-vm-private-b"
      }
    ]
  ])
}

module "vm" {
  for_each = { for vm in local.vm_deployments : vm.instance_name => vm }
  source   = "./modules/compute"

  instance_name          = each.value.instance_name
  instance_type          = var.instance_type
  vpc_id                 = each.value.vpc_id
  subnet_id              = each.value.subnet_id
  ssh_key_name           = var.ssh_key_name
  ssh_access_cidr        = var.management_cidr
  internal_traffic_cidrs = [for vpc in var.vpcs : vpc.vpc_cidr]
  standard_tags          = var.standard_tags
  project_tags           = merge(var.project_tags, { environment = var.environment, Tier = each.value.instance_tier })
}

