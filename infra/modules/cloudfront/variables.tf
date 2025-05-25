# Defining input variables
variable "s3_bucket_domain_name" {
  description = "Domain name of the S3 bucket for static site hosting"
  type        = string
}

variable "alb_domain_name" {
  description = "Domain name of the Application Load Balancer"
  type        = string
}

variable "cloudfront_oai_identity_path" {
  description = "CloudFront Origin Access Identity path for S3 access"
  type        = string
}
