# /terraform/modules/panos/providers.tf
# Declares the providers required by the PAN-OS configuration module.

terraform {
  required_providers {
    panos = {
      source  = "PaloAltoNetworks/panos"
      version = "~> 2.0.0"
    }

    # The random provider is also used in this module, so it must be declared here too.
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}
