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

# --- Define VPCs --- 
variable "vpcs" {
  description = "A map of VPC configurations. The key of each item is the logical name of the VPC (e.g., 'primary', 'secondary')."
  type = map(object({
    vpc_cidr              = string
    public_subnet_a_cidr  = string
    public_subnet_b_cidr  = string
    private_subnet_a_cidr = string
    private_subnet_b_cidr = string
  }))
  default = {
    primary = {
      vpc_cidr              = "10.100.0.0/16"
      public_subnet_a_cidr  = "10.100.10.0/24"
      public_subnet_b_cidr  = "10.100.20.0/24"
      private_subnet_a_cidr = "10.100.30.0/24"
      private_subnet_b_cidr = "10.100.40.0/24"
    },
    secondary = {
      vpc_cidr              = "10.250.0.0/16"
      public_subnet_a_cidr  = "10.250.10.0/24"
      public_subnet_b_cidr  = "10.250.20.0/24"
      private_subnet_a_cidr = "10.250.30.0/24"
      private_subnet_b_cidr = "10.250.40.0/24"
    }
    natasha = {
      vpc_cidr              = "10.15.0.0/16"
      public_subnet_a_cidr  = "10.15.10.0/24"
      public_subnet_b_cidr  = "10.15.20.0/24"
      private_subnet_a_cidr = "10.15.30.0/24"
      private_subnet_b_cidr = "10.15.40.0/24"
    }
    fre = {
      vpc_cidr              = "10.150.0.0/16"
      public_subnet_a_cidr  = "10.150.14.0/24"
      public_subnet_b_cidr  = "10.150.24.0/24"
      private_subnet_a_cidr = "10.150.34.0/24"
      private_subnet_b_cidr = "10.150.44.0/24"
    }
    pat = {
      vpc_cidr              = "10.151.0.0/16"
      public_subnet_a_cidr  = "10.151.14.0/24"
      public_subnet_b_cidr  = "10.151.24.0/24"
      private_subnet_a_cidr = "10.151.34.0/24"
      private_subnet_b_cidr = "10.151.44.0/24"
    }
  }
}
