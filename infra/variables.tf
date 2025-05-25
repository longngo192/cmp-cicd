variable "bucket_name_prefix" {
  description = "Prefix for the S3 bucket name (UUID will be appended for uniqueness)"
  type        = string
  default     = "lab1-cmp-ngosylong-com"
}

variable "alert_email" {
  description = "Email to send notification"
  type        = string
  default     = "ngosylong0@gmail.com"
}