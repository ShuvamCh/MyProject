/*module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.11.0"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}*/

#VPC Creation for Infrastructure
resource "aws_vpc" "myVPC" {
  cidr_block = "10.0.0.0/16"
}

#Security group to add to instances as a layer of firewall
resource "aws_security_group" "name" {

}

#Instance created to deploy
resource "aws_instance" "MyEC2Instance" {
  ami               = data.aws_ami.MyAMI.id
  instance_type     = "t2.micro"
  availability_zone = "us-east-1a"
  count             = 2
  user_data         = file("apache_install.sh")

  /*connection {
    
  }

  provisioner "local-exec" {
    
  }*/
}

#Bucket to store logs
resource "aws_s3_bucket" "MyS3Bucket" {
  bucket = ""
  acl    = "private"

  tags = {
    Name        = local.name
    Environment = "Dev"
  }
}