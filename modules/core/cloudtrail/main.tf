# modules/cloudtrail/main.tf

terraform {
  backend "s3" {}
}

provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

# S3 Bucket for CloudTrail logs
resource "aws_s3_bucket" "cloudtrail_bucket" {
  bucket = var.s3_bucket_name
  tags   = var.tags
}

# S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "cloudtrail_versioning" {
  bucket = aws_s3_bucket.cloudtrail_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket Server-Side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail_encryption" {
  bucket = aws_s3_bucket.cloudtrail_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "cloudtrail_logs" {
  count = var.enable_cloudwatch_logging ? 1 : 0
  name  = "/aws/cloudtrail/${var.cloudtrail_name}"
  retention_in_days = 90
}

# IAM Role for CloudTrail to use CloudWatch
resource "aws_iam_role" "cloudtrail_role" {
  count = var.enable_cloudwatch_logging ? 1 : 0
  name  = "cloudtrail-cloudwatch-logging-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# IAM Role Policy for CloudTrail to use CloudWatch Logs
resource "aws_iam_role_policy" "cloudtrail_policy" {
  count = var.enable_cloudwatch_logging ? 1 : 0
  name  = "cloudtrail-cloudwatch-logging-policy"
  role  = aws_iam_role.cloudtrail_role[0].name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = "logs:CreateLogStream",
        Resource = "${aws_cloudwatch_log_group.cloudtrail_logs[0].arn}:*"
      },
      {
        Effect = "Allow",
        Action = "logs:PutLogEvents",
        Resource = "${aws_cloudwatch_log_group.cloudtrail_logs[0].arn}:*"
      }
    ]
  })
}

# CloudTrail resource
resource "aws_cloudtrail" "cloudtrail" {
  name                          = var.cloudtrail_name
  s3_bucket_name                = aws_s3_bucket.cloudtrail_bucket.bucket
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_logging                = true

  # Conditionally add CloudWatch logs if logging is enabled
  cloud_watch_logs_group_arn = var.enable_cloudwatch_logging ? aws_cloudwatch_log_group.cloudtrail_logs[0].arn : null
  cloud_watch_logs_role_arn  = var.enable_cloudwatch_logging ? aws_iam_role.cloudtrail_role[0].arn : null

  depends_on = [
    aws_s3_bucket.cloudtrail_bucket, 
    aws_cloudwatch_log_group.cloudtrail_logs,  
    aws_iam_role.cloudtrail_role,
    aws_iam_role_policy.cloudtrail_policy,  # Updated dependency
  ]
}

