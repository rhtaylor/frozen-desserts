terraform {
  
  # backend s3{
  #   bucket = "terraform-backend-frozen-desserts"
  #   key = "smfd-infra"
  #   region = "us-east-2"
  # }
   cloud {
    organization = "web_x"

    workspaces {
      name = "SM"
    }
   }


  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = "~> 1.3.2"

}

provider "aws" {
  region = var.region
  default_tags {
    tags = var.prop_tags
    
  }
}


# shell script setups ##

resource "null_resource" "shell" {
  provisioner "local-exec" {
    command = "/bin/bash .railsmigrate-push.sh"
  }
}