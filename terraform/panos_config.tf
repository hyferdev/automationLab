# /terraform/panos_config.tf
# Applies the baseline PAN-OS configuration to each firewall.

# --- Provider Configuration ---
provider "panos" {
  alias    = "pa-az-a"
  hostname = var.panos_api_key != null && var.panos_api_key != "" ? aws_eip.paloalto_mgmt_eip[var.availability_zones[0]].public_ip : "127.0.0.1" # Dummy IP
  api_key  = var.panos_api_key
}

provider "panos" {
  alias    = "pa-az-b"
  hostname = var.panos_api_key != null && var.panos_api_key != "" ? aws_eip.paloalto_mgmt_eip[var.availability_zones[1]].public_ip : "127.0.0.1" # Dummy IP
  api_key  = var.panos_api_key
}

# --- Apply Configuration to Firewall in AZ 'a' ---
module "panos_az_a" {
  # The module is only created if an API key has been provided.
  count = var.panos_api_key != null && var.panos_api_key != "" ? 1 : 0

  source    = "./modules/panos"
  providers = { panos = panos.pa-az-a }

  admin_username = var.panos_admin_username
  admin_password = var.panos_admin_password
}


# --- Apply Configuration to Firewall in AZ 'b' ---
module "panos_az_b" {
  # The module is only created if an API key has been provided.
  count = var.panos_api_key != null && var.panos_api_key != "" ? 1 : 0

  source    = "./modules/panos"
  providers = { panos = panos.pa-az-b }

  admin_username = var.panos_admin_username
  admin_password = var.panos_admin_password
}