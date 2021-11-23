terraform {
  required_version = "~>1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>3.66"
    }
  }
  /*backend "s3" {
    access_key     = "AKIAQ2BZFDP7ZNINDQDU"
    secret_key     = "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"
    bucket         = "terraform-backend-myec2instance"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform_state_lock_table"
  }*/
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "Demo_Project"
    workspaces {
      name = "MyProject"
    }
  }
}

provider "aws" {
  region     = var.aws_region
  access_key = "AKIAQ2BZFDP7ZNINDQDU"
  secret_key = "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"
  #profile    = "default"
  #alias      = "Alias"
}