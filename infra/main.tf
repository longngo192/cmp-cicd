provider "aws" {
  region = "us-east-1"
}
# Create CloudFront Origin Access Identity
resource "aws_cloudfront_origin_access_identity" "main" {
  comment = "OAI for S3 bucket access"
}

# TERRAFORM VPC MODULE
module "vpc" {
  source             = "./modules/vpc"
  project_name       = "webapp"
  vpc_cidr           = "10.0.0.0/16"
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets    = ["10.0.3.0/24", "10.0.4.0/24"]
  availability_zones = ["us-east-1a", "us-east-1b"]
  aws_region         = "us-east-1"
}

# COMPUTE MODULE (EC2 + ASG)
module "compute" {
  source                = "./modules/compute"
  project_name          = "webapp"
  vpc_id                = module.vpc.vpc_id
  private_subnets       = module.vpc.private_subnets
  alb_security_group_id = module.load_balancer.alb_security_group_id
  ami_id                = "ami-05b10e08d247fb927"
  instance_type         = "t2.micro"
  desired_capacity      = 1
  min_size              = 1
  max_size              = 1
  frontend_s3_bucket    = module.s3_bucket.s3_bucket_name
}

# LOAD BALANCER MODULE
module "load_balancer" {
  source           = "./modules/load_balancer"
  project_name     = "webapp"
  vpc_id           = module.vpc.vpc_id
  public_subnets   = module.vpc.public_subnets
  ec2_instance_ids = module.compute.ec2_instance_ids
  asg_name         = module.compute.asg_name
}

# MONITORING MODULE
module "monitoring" {
  source          = "./modules/monitoring"
  project_name    = "webapp"
  alert_email     = var.alert_email
  rds_instance_id = module.rds.rds_instance_id
  asg_name        = module.compute.asg_name
}

# RDS MODULE
module "rds" {
  source                = "./modules/rds"
  project_name          = "webapp"
  vpc_id                = module.vpc.vpc_id
  private_subnets       = module.vpc.private_subnets
  ec2_security_group_id = module.compute.backend_ec2_sg_id
  # bastion_security_group_id = module.rds_bastion.bastion_sg_id
  instance_class        = "db.t3.micro"
  allocated_storage     = 20
  max_allocated_storage = 100
  db_username           = "dbadmin"
  db_password           = "dbadmin11"
}

# RDS Bastion Module for testing
module "rds_bastion" {
  source           = "./modules/rds_bastion"
  ami_id           = "ami-0953476d60561c955" # Amazon Linux 2023 AMI
  instance_type    = "t3.micro"
  public_subnet_id = module.vpc.private_subnets[0]
  vpc_id           = module.vpc.vpc_id
}

# module "efs" {
#   source                = "./modules/efs"
#   project_name          = "webapp"
#   vpc_id                = module.vpc.vpc_id
#   private_subnets       = module.vpc.private_subnets
#   ec2_security_group_id = module.compute.backend_ec2_sg_id
#   kms_key_arn           = module.security.kms_key_arn
# }

module "s3_bucket" {
  source                 = "./modules/s3"
  bucket_name_prefix     = var.bucket_name_prefix
  cloudfront_oai_iam_arn = aws_cloudfront_origin_access_identity.main.iam_arn
}

module "cloudfront" {
  source                       = "./modules/cloudfront"
  s3_bucket_domain_name        = module.s3_bucket.s3_bucket_domain_name
  alb_domain_name              = module.load_balancer.alb_dns_name
  cloudfront_oai_identity_path = aws_cloudfront_origin_access_identity.main.cloudfront_access_identity_path
}


# SECURITY MODULE
module "security" {
  source       = "./modules/security"
  project_name = "webapp"
  vpc_id       = module.vpc.vpc_id
  alb_arn      = module.load_balancer.alb_arn
}
