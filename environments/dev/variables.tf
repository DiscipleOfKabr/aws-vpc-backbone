variable "aws_region" {

  description = "The AWS region to deploy into"
  type        = string
  default     = "eu-central-1"
}

variable "app_port" {
  type    = number
  default = 80
}

variable "https_port" {
  type    = number
  default = 443
}


