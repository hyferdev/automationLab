# /terraform/modules/tgw/outputs.tf

output "transit_gateway_id" {
  description = "The ID of the EC2 Transit Gateway."
  value       = aws_ec2_transit_gateway.main.id
}

output "transit_gateway_arn" {
  description = "The ARN of the EC2 Transit Gateway."
  value       = aws_ec2_transit_gateway.main.arn
}

output "default_route_table_id" {
  description = "The ID of the default association route table."
  value       = aws_ec2_transit_gateway.main.association_default_route_table_id
}
