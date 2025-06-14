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
