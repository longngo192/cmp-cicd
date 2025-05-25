variable "project_name" {
  type    = string
  default = "webapp"
}

variable "vpc_id" {
  type = string
}

variable "private_subnets" {
  type = list(string)
}

variable "alb_security_group_id" {
  type = string
}

# Amazon Linux 2023 AMI with pre installed ssm agent
variable "ami_id" {
  type    = string
  default = "ami-0953476d60561c955"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "desired_capacity" {
  type    = number
  default = 1
}

variable "min_size" {
  type    = number
  default = 1
}

variable "max_size" {
  type    = number
  default = 1
}

variable "frontend_s3_bucket" {
  type = string
}
