terraform {
  required_providers {
    aws = {
      version = "5.89.0"
    }
  }

  backend "s3" {
    bucket  = "ngosylong0-terraform-bucket"
    key     = "infra/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}