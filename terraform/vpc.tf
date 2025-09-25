# /terraform/vpc.tf
# Defines all VPCs and calls the VPC module to create them.

module "vpc" {
  for_each = var.vpcs
  source   = "./modules/vpc"

  # General VPC and Subnet Configuration
  vpc_cidr                      = each.value.vpc_cidr
  public_subnet_a_cidr          = try(each.value.public_subnet_a_cidr, null)
  public_subnet_b_cidr          = try(each.value.public_subnet_b_cidr, null)
  private_subnet_a_cidr         = each.value.private_subnet_a_cidr
  private_subnet_b_cidr         = each.value.private_subnet_b_cidr

  # Security VPC Specific Subnets (will be null for spoke VPCs)
  gwlb_endpoint_subnet_a_cidr   = each.value.gwlb_endpoint_subnet_a_cidr
  gwlb_endpoint_subnet_b_cidr   = each.value.gwlb_endpoint_subnet_b_cidr
  management_subnet_a_cidr      = each.value.management_subnet_a_cidr
  management_subnet_b_cidr      = each.value.management_subnet_b_cidr
  egress_subnet_a_cidr          = each.value.egress_subnet_a_cidr
  egress_subnet_b_cidr          = each.value.egress_subnet_b_cidr


  # Shared Configuration
  availability_zones = var.availability_zones
  project_name       = "${var.project_name}-${each.key}"
  environment        = var.environment
  standard_tags      = var.standard_tags
  project_tags       = merge(var.project_tags, { environment = var.environment })
  transit_gateway_id = module.tgw.transit_gateway_id
}

# --- Define all VPCs in the environment ---
variable "vpcs" {
  description = "A map of all VPC configurations in the environment."
  type = map(object({
    vpc_cidr                      = string
    public_subnet_a_cidr          = optional(string, null)
    public_subnet_b_cidr          = optional(string, null)
    private_subnet_a_cidr         = string
    private_subnet_b_cidr         = string
    gwlb_endpoint_subnet_a_cidr   = optional(string, null)
    gwlb_endpoint_subnet_b_cidr   = optional(string, null)
    management_subnet_a_cidr      = optional(string, null)
    management_subnet_b_cidr      = optional(string, null)
    egress_subnet_a_cidr          = optional(string, null)
    egress_subnet_b_cidr          = optional(string, null)
  }))
  default = {
    des = {
      vpc_cidr                = "10.100.0.0/16"
      public_subnet_a_cidr    = "10.100.10.0/24"
      public_subnet_b_cidr    = "10.100.20.0/24"
      private_subnet_a_cidr   = "10.100.30.0/24"
      private_subnet_b_cidr   = "10.100.40.0/24"
    },
    natasha = {
      vpc_cidr                = "10.15.0.0/16"
      public_subnet_a_cidr    = "10.15.10.0/24"
      public_subnet_b_cidr    = "10.15.20.0/24"
      private_subnet_a_cidr   = "10.15.30.0/24"
      private_subnet_b_cidr   = "10.15.40.0/24"
    },
    fre = {
      vpc_cidr                = "10.150.0.0/16"
      public_subnet_a_cidr    = "10.150.14.0/24"
      public_subnet_b_cidr    = "10.150.24.0/24"
      private_subnet_a_cidr   = "10.150.34.0/24"
      private_subnet_b_cidr   = "10.150.44.0/24"
    },
    pat = {
      vpc_cidr                = "10.151.0.0/16"
      public_subnet_a_cidr    = "10.151.14.0/24"
      public_subnet_b_cidr    = "10.151.24.0/24"
      private_subnet_a_cidr   = "10.151.34.0/24"
      private_subnet_b_cidr   = "10.151.44.0/24"
    },
    security = {
      vpc_cidr                      = "10.0.0.0/16"
      private_subnet_a_cidr         = "10.0.3.0/24" # TGW/GENEVE interface
      private_subnet_b_cidr         = "10.0.4.0/24" # TGW/GENEVE interface
      gwlb_endpoint_subnet_a_cidr   = "10.0.5.0/24"
      gwlb_endpoint_subnet_b_cidr   = "10.0.6.0/24"
      management_subnet_a_cidr      = "10.0.7.0/24"
      management_subnet_b_cidr      = "10.0.8.0/24"
      egress_subnet_a_cidr          = "10.0.9.0/24"
      egress_subnet_b_cidr          = "10.0.10.0/24"
    }
  }
}