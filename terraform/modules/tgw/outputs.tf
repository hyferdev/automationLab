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

output "inbound_route_table_id" {
  description = "The ID of the TGW route table used by Spoke VPCs."
  value       = aws_ec2_transit_gateway_route_table.inbound_rt.id
}

output "outbound_route_table_id" {
  description = "The ID of the TGW route table used by the Security VPC."
  value       = aws_ec2_transit_gateway_route_table.outbound_rt.id
}