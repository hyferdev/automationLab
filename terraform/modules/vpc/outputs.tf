# /terraform/modules/vpc/outputs.tf
# Outputs from the VPC module.

output "vpc_id" {
  description = "The ID of the created VPC."
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "A list of the public subnet IDs."
  value       = [aws_subnet.public_a.id, aws_subnet.public_b.id]
}

output "private_subnet_ids" {
  description = "A list of the private subnet IDs."
  value       = [aws_subnet.private_a.id, aws_subnet.private_b.id]
}

output "private_subnet_ids_by_az" {
  description = "A map of private subnet IDs, keyed by AZ."
  value = {
    "${var.availability_zones[0]}" = aws_subnet.private_a.id,
    "${var.availability_zones[1]}" = aws_subnet.private_b.id
  }
}

output "appliance_subnet_ids" {
  description = "A list of the appliance subnet IDs."
  value       = aws_subnet.appliance_a.*.id
}

output "gwlb_endpoint_subnet_ids" {
  description = "A list of the GWLB endpoint subnet IDs."
  value       = aws_subnet.gwlb_endpoint_a.*.id
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway."
  value       = aws_internet_gateway.main_gw.id
}

output "transit_gateway_attachment_id" {
  description = "The ID of the Transit Gateway VPC attachment."
  value       = aws_ec2_transit_gateway_vpc_attachment.main.id
}
