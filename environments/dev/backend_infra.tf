variable "env_name" {

  type        = string
  description = "User input dev or prod"
  default     = "dev"
}



resource "random_string" "suffix" {

  length  = 6
  special = false
  upper   = false

}
#resource "aws_s3_bucket" "terraform_state" {
#  bucket        = "${var.env_name}-tfstate-storage-${random_string.suffix.result}"
#  force_destroy = true
#
#
#
#   tags  = {
#
#    Name        = "${var.env_name}-tfstate-storage"
#    Environment = var.env_name
#
#  }
#}



#resource "aws_s3_bucket_versioning" "state_versioning" {
#  bucket = aws_s3_bucket.terraform_state.id
#  versioning_configuration {
#
#    status = "Enabled"
#  }
#}


#resource "aws_s3_bucket_server_side_encryption_configuration" "state_encryption" {
#
#  bucket = aws_s3_bucket.terraform_state.id
#
#  rule {
#
#    apply_server_side_encryption_by_default {
#      sse_algorithm = "AES256"
#    }
#  }
#}


#resource "aws_dynamodb_table" "terraform_locks" {
#  name         = "${var.env_name}-tfstatelocks"
#  billing_mode = "PAY_PER_REQUEST"
#  hash_key     = "LockID"
#  attribute {
#
#    name = "LockID"
#    type = "S"
#  }



#  tags = {
#    Name        = "${var.env_name}-tfstate-locks"
#    Environment = var.env_name
#  }

#}