variable "private_security_group_id" {

  type        = string
  description = "The ID of the security group for the private backend instances"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "A list of private subnet IDs for the Auto Scaling Group in the compute module"
}

variable "vpc_id" {

  type        = string
  description = "The ID of the vpc"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of all subnet names"
}

variable "alb_sg_id" {
  type        = string
  description = "The ID of the security group for the automatic load balancer."
}

variable "env_name" {
    type = string
    description = "The name of the current environment"
}

variable "app_port" {
    type = number
    description = "The network port used by the application backend" 
}

variable "backend_profile_name" {
    type = string
    description = "The name of the IAM profile"
}
