output "vpc_id" {
  description = "ID of the main VPC"
  value       = aws_vpc.main_vpc.id
}

output "public_subnet_a_id" {
  description = "Public subnet A ID"
  value       = aws_subnet.public_a.id
}

output "public_subnet_b_id" {
  description = "Public subnet B ID"
  value       = aws_subnet.public_b.id
}

output "private_subnet_a_id" {
  description = "Private subnet A ID"
  value       = aws_subnet.private_a.id
}

output "private_subnet_b_id" {
  description = "Private subnet B ID"
  value       = aws_subnet.private_b.id
}
