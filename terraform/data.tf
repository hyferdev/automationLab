# /terraform/data.tf
# This file contains data sources to look up dynamic information.

data "aws_ssm_parameters_by_path" "paloalto_amis" {
  path = "/aws/service/marketplace/prod-hhtxhxwx3jg6k/"
}

locals {
    sorted_ami_parameters = sort(data.aws_ssm_parameters_by_path.paloalto_amis.names)
    latest_ami_parameter = local.sorted_ami_parameters[length(local.sorted_ami_parameters) - 1]
}

data "aws_ssm_parameter" "paloalto" {
  name = local.latest_ami_parameter
}