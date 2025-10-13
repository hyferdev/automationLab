# /terraform/modules/panos/variables.tf

variable "admin_username" {
  description = "The username for the new superuser administrator."
  type        = string
}

variable "admin_password" {
  description = "The password for the new superuser administrator."
  type        = string
  sensitive   = true
}
