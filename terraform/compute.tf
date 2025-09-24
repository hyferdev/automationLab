# /terraform/compute.tf
# This file defines the EC2 instances to be created in the spoke VPCs.

locals {
  vms_to_create = merge(
    # Create one private VM for each spoke VPC
    {
      for vpc_key, vpc_details in module.vpc :
      "${vpc_key}-private" => {
        instance_name = "${var.project_name}-${vpc_key}-${var.environment}-vm-private"
        vpc_id        = vpc_details.vpc_id
        subnet_id     = vpc_details.private_subnet_ids[0]
      } if vpc_key != "security"
    },
    # Only create a public VM if the VPC has public subnets
    {
      for vpc_key, vpc_details in module.vpc :
      "${vpc_key}-public" => {
        instance_name = "${var.project_name}-${vpc_key}-${var.environment}-vm-public"
        vpc_id        = vpc_details.vpc_id
        subnet_id     = vpc_details.public_subnet_ids[0]
      } if vpc_key != "security" && length(vpc_details.public_subnet_ids) > 0
    }
  )
}

module "vm" {
  for_each = local.vms_to_create
  source   = "./modules/compute"

  instance_name          = each.value.instance_name
  instance_type          = var.instance_type
  vpc_id                 = each.value.vpc_id
  subnet_id              = each.value.subnet_id
  ssh_key_name           = var.ssh_key_name
  ssh_access_cidr        = var.management_cidr
  internal_traffic_cidrs = [for vpc in values(var.vpcs) : vpc.vpc_cidr]
  standard_tags          = var.standard_tags
  project_tags           = merge(var.project_tags, { environment = var.environment })
}

