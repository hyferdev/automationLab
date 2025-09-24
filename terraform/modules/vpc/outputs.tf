# /terraform/modules/vpc/outputs.tf
# Outputs from the VPC module.

output "vpc_id" {
  description = "The ID of the created VPC."
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "A list of the public subnet IDs."
  value       = concat(aws_subnet.public_a.*.id, aws_subnet.public_b.*.id)
}

output "private_subnet_ids" {
  description = "A list of the private subnet IDs."
  value       = [aws_subnet.private_a.id, aws_subnet.private_b.id]
}

output "transit_gateway_attachment_id" {
  description = "The ID of the Transit Gateway VPC attachment."
  value       = aws_ec2_transit_gateway_vpc_attachment.main.id
}

# --- Output for Internet Gateway ---
output "internet_gateway_id" {
  description = "The ID of the Internet Gateway."
  value       = aws_internet_gateway.main_gw.id
}


# --- Outputs for Palo Alto Multi-Interface Design ---
output "management_subnet_ids_by_az" {
  description = "A map of management subnet IDs, keyed by Availability Zone."
  value = merge(
    { for s in aws_subnet.management_a : s.availability_zone => s.id },
    { for s in aws_subnet.management_b : s.availability_zone => s.id }
  )
}

output "egress_subnet_ids_by_az" {
  description = "A map of egress subnet IDs, keyed by Availability Zone."
  value = merge(
    { for s in aws_subnet.egress_a : s.availability_zone => s.id },
    { for s in aws_subnet.egress_b : s.availability_zone => s.id }
  )
}

output "private_subnet_ids_by_az" {
  description = "A map of private subnet IDs (used for TGW/GENEVE), keyed by AZ."
  value = {
    (aws_subnet.private_a.availability_zone) = aws_subnet.private_a.id,
    (aws_subnet.private_b.availability_zone) = aws_subnet.private_b.id
  }
}

output "gwlb_endpoint_subnet_ids_by_az" {
  description = "A map of GWLB endpoint subnet IDs, keyed by Availability Zone."
  value = merge(
    { for s in aws_subnet.gwlb_endpoint_a : s.availability_zone => s.id },
    { for s in aws_subnet.gwlb_endpoint_b : s.availability_zone => s.id }
  )
}

