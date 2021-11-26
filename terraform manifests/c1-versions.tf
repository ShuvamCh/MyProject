#Terraform Block
terraform {
  required_version = "~>1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>3.66"
    }
  }
  #S3 can be used as remote backend as well to store state files. Configuration below
  backend "s3" {
    access_key     = "AKIAQ2BZFDP7YIZG7T6X"
    secret_key     = "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"
    bucket         = "terraform-backend-myec2instance"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform_state_lock_table"
  }

  #Remote backend using terraform cloud
  /*backend "remote" {
    hostname     = "app.terraform.io"
    organization = "Demo_Project"
    workspaces {
      name = "MyProject"
    }
  }*/
}

#Provider Block
provider "aws" {
  region     = var.aws_region
  access_key = "AKIAQ2BZFDP7YIZG7T6X"
  secret_key = "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"
  profile    = "default"
  #alias      = "Alias"    #Alias required when we need to use multiple providers
}