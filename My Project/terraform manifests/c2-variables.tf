variable "aws_region" {
  description = "Region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "Instance type for EC2 instances"
  default     = "t2.micro"
  type        = string
}

locals {
  name = "boto"
}