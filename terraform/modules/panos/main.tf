# /terraform/modules/panos/main.tf
# Configures a Palo Alto firewall with a new admin and disables the default admin.

# --- Create Your New Administrator ---
resource "panos_administrator" "new_admin" {
  name          = var.admin_username
  password      = var.admin_password
  superuser     = true
}

# --- Disable the Default 'admin' User ---
# This takes control of the built-in admin user and sets its password
# to a long, random string that is not stored in state, effectively disabling it.
resource "random_password" "default_admin_password" {
  length  = 32
  special = true
}

resource "panos_administrator" "disable_default_admin" {
  name     = "admin"
  password = random_password.default_admin_password.result
}