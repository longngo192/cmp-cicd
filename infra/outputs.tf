output "rds_endpoint" {
  value = module.rds.rds_endpoint
}

output "frontend_url" {
  value = module.cloudfront.cloudfront_domain_name
}

output "alb_dns_name" {
  value = module.load_balancer.alb_dns_name
}