output "s3_bucket_domain_name" {
  description = "Domain name of the S3 bucket"
  value       = aws_s3_bucket.static_site.bucket_regional_domain_name
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.static_site.arn
}

output "s3_bucket_name" {
  description = "ARN of the S3 bucket"
  value       = local.bucket-name
}