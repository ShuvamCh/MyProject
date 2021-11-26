#VPC Through Terraform module
/*
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~>3.11.0"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}
*/
#Manual VPC Creation for Infrastructure
resource "aws_vpc" "myVPC" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "MyProjectVPC"
  }
}

#internet Gateway
resource "aws_internet_gateway" "myVPC-Gateway" {
  vpc_id     = aws_vpc.myVPC.id
  depends_on = [aws_vpc.myVPC]

  tags = {
    Name = "MyProjectVPC-IG"
  }
}

#Subnets
resource "aws_subnet" "Public" {
  #count                   = length(data.aws_availability_zones.available)
  vpc_id                  = aws_vpc.myVPC.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  #availability_zone       = data.aws_availability_zones.available[count.index]
  tags = {
    Name = "Public-Subnet1-MyProjectVPC"
  }
}

resource "aws_subnet" "Private" {
  vpc_id                  = aws_vpc.myVPC.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "us-east-1c"

  tags = {
    Name = "Private-Subnet-MyProjectVPC"
  }
}

#Elastic IP for NAT
resource "aws_eip" "nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.myVPC-Gateway]
}

#NAT
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.Private.id
  depends_on    = [aws_internet_gateway.myVPC-Gateway]
  tags = {
    Name        = "nat"
    Environment = "dev"
  }
}

#Route Table
resource "aws_route_table" "PublicRoute" {
  vpc_id = aws_vpc.myVPC.id
  tags = {
    Name = "Public-Route"
  }
}

resource "aws_route" "Public-Route" {
  route_table_id         = aws_route_table.PublicRoute.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.myVPC-Gateway.id
}

resource "aws_route_table_association" "PublicRouteAssociation" {
  subnet_id      = aws_subnet.Public.id
  route_table_id = aws_route_table.PublicRoute.id
}

resource "aws_route_table" "PrivateRoute" {
  vpc_id = aws_vpc.myVPC.id
  tags = {
    Name = "Private-Route"
  }
}

resource "aws_route" "Private-Route" {
  route_table_id         = aws_route_table.PrivateRoute.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.nat.id
}

resource "aws_route_table_association" "PrivateRouteAssociation" {
  subnet_id      = aws_subnet.Private.id
  route_table_id = aws_route_table.PrivateRoute.id
}

#Security Group using Terraform Dynamic Block
locals {
  ports = [80, 443, 8080, 8081, 7080, 7081]
}

resource "aws_security_group" "sg-dynamic" {
  name        = "sg_myproject"
  description = "sg_myproject"
  vpc_id      = aws_vpc.myVPC.id

  dynamic "ingress" {
    for_each = local.ports
    content {
      description      = "description-${ingress.key}"
      from_port        = ingress.value
      to_port          = ingress.value
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = null
      security_groups  = null
      self             = null
    }
  }
  dynamic "egress" {
    for_each = local.ports
    content {
      description      = "description ${egress.key}"
      from_port        = egress.value
      to_port          = egress.value
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = null
      security_groups  = null
      self             = null
    }
  }

  tags = {
    Name = "sg_myproject"
  }
}

resource "aws_instance" "MyEC2Instance-Public" {
  ami           = data.aws_ami.MyAMI.id
  instance_type = "t2.micro"
  key_name      = "Terraform"
  monitoring    = true
  subnet_id     = aws_subnet.Public.id
  count         = 2
  vpc_security_group_ids = [aws_security_group.sg-dynamic.id]

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Name        = "Public_Instance-${count.index}"
  }
  provisioner "local-exec" {
    #count = length(aws_instance.MyEC2Instance)
    command     = "echo ${self.public_ip} >> Creation_Time_Public_IP.txt"
    working_dir = "local_exec_output_files/"
    on_failure  = continue
  }
}

resource "aws_instance" "MyEC2Instance-Private" {
  ami           = data.aws_ami.MyAMI.id
  instance_type = "t2.micro"
  key_name      = "Terraform"
  monitoring    = true
  subnet_id     = aws_subnet.Private.id
  #availability_zone = "us-east-1a"
  vpc_security_group_ids = [aws_security_group.sg-dynamic.id]

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Name        = "Private_Instance"
  }
}

locals {
  common_tags = {
    environment = "dev"
  }
}

resource "aws_alb" "MyProject-ALB" {
  name                       = "myproject-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.sg-dynamic.id]
  subnets                    = [aws_subnet.Public.id]
  enable_deletion_protection = false

  tags = local.common_tags
}
resource "aws_lb_target_group" "MyProject-ALB" {
  name     = "myProject-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.myVPC.id

  tags = local.common_tags
}

resource "aws_lb_listener" "MyProject-ALB-Listner" {
  load_balancer_arn = aws_alb.MyProject-ALB.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.MyProject-ALB.arn
  }

  tags = local.common_tags
}

resource "aws_lb_target_group_attachment" "MyProject-ALB1" {
  count            = length(aws_instance.MyEC2Instance-Public)
  target_group_arn = aws_lb_target_group.MyProject-ALB.arn
  target_id        = aws_instance.MyEC2Instance-Public[count.index].id
  port             = 80
}

resource "aws_lb_target_group_attachment" "MyProject-ALB2" {
  count            = length(aws_instance.MyEC2Instance-Public)
  target_group_arn = aws_lb_target_group.MyProject-ALB.arn
  target_id        = aws_instance.MyEC2Instance-Public[count.index].id
  port             = 80
}

module "AWS_S3" {
  source = "../module/AWS S3 Bucket"
  bucket_name = var.bucket_name
  tags = var.s3_tags
}