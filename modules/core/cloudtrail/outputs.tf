# modules/cloudtrail/outputs.tf

output "cloudtrail_s3_bucket" {
  value = aws_s3_bucket.cloudtrail_bucket.bucket
}

output "cloudtrail_arn" {
  value = aws_cloudtrail.cloudtrail.arn
}


output "cloudwatch_log_group_arn" {
  value       = var.enable_cloudwatch_logging ? aws_cloudwatch_log_group.cloudtrail_logs[0].arn : ""
  description = "ARN of the CloudWatch Logs log group"
}


output "cloudtrail_iam_role_arn" {
  value       = var.enable_cloudwatch_logging ? aws_iam_role.cloudtrail_role[0].arn : ""
  description = "ARN of the IAM role used by CloudTrail"
}

