terraform {
#after tunning terraform apply (with local backend)
# you will uncomment this code then return terraform init
# to switch from local backend to remote aws backend
#   backend "s3" {
#     bucket = "devops-directive-tf-state"
#     key = "02-basic/import-bootstrap/terraform.tfstate"
#     region = "us-east-1"
#     dynamodb_table = "terraform-state-locking"
#     encrypt = true
#   }

  required_providers {
    aws={
        source = "hashicorp/aws"
        version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "terraform_state_bk" {
  bucket = "bucket-example-tf-1" #replace with your bucket name
  force_destroy = true
}
resource "aws_s3_bucket_versioning" "terraform_bucket_versioning" {
  bucket = aws_s3_bucket.terraform_state_bk.id
  versioning_configuration {
    status = "Enabled"
  }
}
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_crypto_conf" {
  bucket        = aws_s3_bucket.terraform_state_bk.bucket 
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
resource "aws_dynamodb_table" "terraform_locks" {
  name = "terraform-state-locking"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}