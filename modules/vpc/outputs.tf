
output "private_subnet_ids" {
  description = "A list of the private subnet IDs"
  value = [
    for key, config in var.subnet_configs :
    aws_subnet.main[key].id if config.type == "private"
  ]
}

output "vpc_id" {
  value       = aws_vpc.backbone.id
  description = "The ID of the created VPC"
}

output "public_subnet_ids" {
  description = "A list of the public subnet IDs"
  value = [
    for key, config in var.subnet_configs :
    aws_subnet.main[key].id if config.type == "public"
  ]
}

