# Defining input variables
variable "bucket_name_prefix" {
  description = "Prefix for the S3 bucket name (UUID will be appended for uniqueness)"
  type        = string
}

variable "cloudfront_oai_iam_arn" {
  description = "IAM ARN of the CloudFront OAI"
  type        = string
}
