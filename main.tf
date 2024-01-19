terraform {
  
  backend s3{
    bucket = "terraform-backend-frozen-desserts"
    key = "smfd-infra"
    region = "us-east-2"
  }


  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = "~> 1.6.6"

}

provider "aws" {
  region = var.region
  default_tags {
    tags = var.prop_tags
    
  }
}
