# /terraform/init-cfg.tpl
# This template is used to generate the init-cfg.txt file.

# Basic operational settings
type=dhcp-client
op-command-modes=jumbo-frame
op-command-modes=mgmt-interface-swap
plugin-op-commands=aws-gwlb-inspect:enable
plugin-op-commands=aws-gwlb-overlay-routing:enable