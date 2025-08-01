# --- Compute ---
# Call the compute module once for each subnet.

module "vm_public_b" {
  source = "./modules/compute"

  instance_name          = "${var.project_name}-${var.environment}-vm-public-b"
  instance_type          = var.instance_type
  vpc_id                 = module.vpc.vpc_id
  subnet_id              = module.vpc.public_subnet_ids[1]
  ssh_key_name           = var.ssh_key_name
  ssh_access_cidr        = var.management_cidr
  internal_traffic_cidrs = [var.vpc_cidr, var.secondary_vpc_cidr]
  standard_tags          = var.standard_tags
  project_tags           = merge(var.project_tags, { environment = var.environment })
}

module "vm_private_a" {
  source = "./modules/compute"

  instance_name          = "${var.project_name}-${var.environment}-vm-private-a"
  instance_type          = var.instance_type
  vpc_id                 = module.vpc.vpc_id
  subnet_id              = module.vpc.private_subnet_ids[0]
  ssh_key_name           = var.ssh_key_name
  ssh_access_cidr        = var.management_cidr
  internal_traffic_cidrs = [var.vpc_cidr, var.secondary_vpc_cidr]
  standard_tags          = var.standard_tags
  project_tags           = merge(var.project_tags, { environment = var.environment })
}

module "vm_secondary_private_a" {
  source = "./modules/compute"

  instance_name          = "${var.project_name}-secondary-${var.environment}-vm-private-a"
  instance_type          = var.instance_type
  vpc_id                 = module.vpc_secondary.vpc_id
  subnet_id              = module.vpc_secondary.private_subnet_ids[0]
  ssh_key_name           = var.ssh_key_name
  ssh_access_cidr        = var.management_cidr
  internal_traffic_cidrs = [var.vpc_cidr, var.secondary_vpc_cidr]
  standard_tags          = var.standard_tags
  project_tags           = merge(var.project_tags, { environment = var.environment })
}
