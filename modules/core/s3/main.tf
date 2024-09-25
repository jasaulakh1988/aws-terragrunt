# modules/core/s3/main.tf
terraform {
  backend "s3" {}
}
 

resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name

  tags = {
    Name        = var.bucket_name
    Environment = var.environment
  }
}

# New aws_s3_bucket_acl resource to manage ACL
#resource "aws_s3_bucket_acl" "this" {
#  bucket = aws_s3_bucket.this.id
#  acl    = "private"
#}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Use a separate resource for versioning
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.bucket

  versioning_configuration {
    status = "Enabled"
  }
}

output "bucket_id" {
  value = aws_s3_bucket.this.id
}

