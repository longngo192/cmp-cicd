# Security Module
# Define the IP set for bad IP addresses
resource "aws_wafv2_ip_set" "bad_ips" {
  name               = "bad-ips"
  description        = "IP set containing bad IP addresses to block"
  scope              = "REGIONAL" # Use "CLOUDFRONT" for CloudFront, "REGIONAL" for ALB/API Gateway
  ip_address_version = "IPV4"
  addresses = [
    "192.0.2.1/32",  # Example bad IP (single IP)
    "203.0.113.0/24" # Example bad IP range
  ]

  tags = {
    Name = "bad-ips"
  }
}

# Define the Web ACL
resource "aws_wafv2_web_acl" "web_acl" {
  name        = "${var.project_name}-waf"
  description = "Web ACL to block bad IP addresses"
  scope       = "REGIONAL" # Use "CLOUDFRONT" for CloudFront, "REGIONAL" for ALB/API Gateway

  default_action {
    allow {} # Allow requests by default unless they match a rule
  }

  # Rule to block bad IPs
  rule {
    name     = "block-bad-ips"
    priority = 1 # Lower priority numbers are evaluated first

    action {
      block {} # Block requests matching this rule
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.bad_ips.arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "block-bad-ips"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.project_name}metrics"
    sampled_requests_enabled   = true
  }

  tags = {
    Name = "example-web-acl"
  }
}
# Associate the Web ACL with an Application Load Balancer (ALB)
resource "aws_wafv2_web_acl_association" "alb_association" {
  resource_arn = var.alb_arn # Replace with your ALB ARN
  web_acl_arn  = aws_wafv2_web_acl.web_acl.arn
}


# KMS Key for Encryption
resource "aws_kms_key" "kms_key" {
  description             = "KMS key for encrypting resources"
  deletion_window_in_days = 30
}

resource "aws_kms_alias" "kms_alias" {
  name          = "alias/${var.project_name}-kms"
  target_key_id = aws_kms_key.kms_key.key_id
}
