variable "env_name" {
  type        = string
  description = "The name of the environment, used for naming resources"
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC where security groups will be created"
}

variable "app_port" {
  type        = number
  description = "The network port used by the application backend"
}

variable "https_port" {
  type        = number
  description = "The secure network port used for HTTPS traffic"
}