

output "alb_sg_id" {
  value = aws_security_group.alb_sg.id
}

output "private_security_group_id" {
  value = aws_security_group.private_sg.id
}

output "backend_profile_name" {
  value = aws_iam_instance_profile.backend_profile.name
}

