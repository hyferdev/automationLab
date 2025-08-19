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

  appliance_subnet_a_cidr     = each.value.appliance_subnet_a_cidr
  appliance_subnet_b_cidr     = each.value.appliance_subnet_b_cidr
  gwlb_endpoint_subnet_a_cidr = each.value.gwlb_endpoint_subnet_a_cidr
  gwlb_endpoint_subnet_b_cidr = each.value.gwlb_endpoint_subnet_b_cidr
  
  availability_zones     = var.availability_zones
  project_name           = "${var.project_name}-${each.key}"
  environment            = var.environment
  standard_tags          = var.standard_tags
  project_tags           = merge(var.project_tags, { environment = var.environment })
  transit_gateway_id     = module.tgw.transit_gateway_id
  all_vpc_cidrs        = { for k, v in var.vpcs : k => v.vpc_cidr }
}

# --- VPC Definitions ---
variable "vpcs" {
  description = "A map of VPC configurations."
  type = map(object({
    vpc_cidr                    = string
    public_subnet_a_cidr        = string
    public_subnet_b_cidr        = string
    private_subnet_a_cidr       = string
    private_subnet_b_cidr       = string
    appliance_subnet_a_cidr     = optional(string)
    appliance_subnet_b_cidr     = optional(string)
    gwlb_endpoint_subnet_a_cidr = optional(string)
    gwlb_endpoint_subnet_b_cidr = optional(string)
  }))
  default = {
    security = {
      vpc_cidr                    = "10.0.0.0/16"
      public_subnet_a_cidr        = "10.0.1.0/24"
      public_subnet_b_cidr        = "10.0.2.0/24"
      private_subnet_a_cidr       = "10.0.3.0/24" # TGW Attachment Subnet
      private_subnet_b_cidr       = "10.0.4.0/24" # TGW Attachment Subnet
      appliance_subnet_a_cidr     = "10.0.10.0/24" # FortiGate-A Subnet
      appliance_subnet_b_cidr     = "10.0.11.0/24" # FortiGate-B Subnet
      gwlb_endpoint_subnet_a_cidr = "10.0.20.0/24" # GWLB Endpoint-A Subnet
      gwlb_endpoint_subnet_b_cidr = "10.0.21.0/24" # GWLB Endpoint-B Subnet
    },
    des = {
      vpc_cidr              = "10.100.0.0/16"
      public_subnet_a_cidr  = "10.100.10.0/24"
      public_subnet_b_cidr  = "10.100.20.0/24"
      private_subnet_a_cidr = "10.100.30.0/24"
      private_subnet_b_cidr = "10.100.40.0/24"
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
