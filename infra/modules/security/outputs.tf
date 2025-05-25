output "kms_key_arn" {
  value = aws_kms_key.kms_key.arn
}

output "waf_acl_id" {
  value = aws_wafv2_web_acl.web_acl.id
}
