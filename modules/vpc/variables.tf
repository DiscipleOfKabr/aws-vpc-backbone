variable "vpc_cidr" {

  type = string

  description = "cidr values declare to default"
  default     = "10.0.0.0/16"
}

variable "env_name" {
  type        = string
  description = "The name of the environment passed down from the root context"
}

variable "public_subnet_cidr" {
  type        = string
  description = "The CIDR block for the public subnet"

}

variable "private_subnet_cidr" {
  type        = string
  description = "The CIDR block for the private subnet."
}




