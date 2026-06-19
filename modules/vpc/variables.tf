variable "vpc_cidr" {

  type = string

  description = "cidr values declare to default,e.g (10.0.0.0/16)"

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




variable "subnet_configs" {
  type = map(object({
    cidr   = string
    az     = string
    type   = string
    nat_gw = bool
  }))

  default = {
    "public_1a"  = { cidr = "10.10.0.0/24", az = "eu-central-1a", type = "public", nat_gw = true }
    "public_1b"  = { cidr = "10.10.1.0/24", az = "eu-central-1b", type = "public", nat_gw = true }
    "private_1a" = { cidr = "10.10.10.0/24", az = "eu-central-1a", type = "private", nat_gw = false }
    "private_1b" = { cidr = "10.10.11.0/24", az = "eu-central-1b", type = "private", nat_gw = false }
  }
}


