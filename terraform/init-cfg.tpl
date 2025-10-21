# /terraform/init-cfg.tpl
# This template is used to generate the init-cfg.txt file.

# Basic operational settings
type=dhcp-client
op-command-modes=jumbo-frame

# Set the initial password for the 'admin' user
admin-password=${initial_password}