#Variable name for aws region where resources will be deployed
variable "aws_region" {
  description = "Region to deploy resources"
  type        = string
  default     = "us-east-1"
}

#Variable name of instance type
variable "instance_type" {
  description = "Instance type for EC2 instances"
  default     = "t2.micro"
  type        = string
}

#locals can be used anywhere in the code. part of DRY principle to avoid repetation.
locals {
  name = "new-resource"
}

variable "bucket_name" {
  description = "Name of the bucket"
  type        = string
  default     = "mybucketnoshuvam12345"
}

variable "s3_tags" {
  description = "Tags to set on the bucket"
  type        = map(string)
  default = {
    Terraform   = "true"
    Environment = "dev"
  }
}