#Instance Public IP as output
output "ec2_instance_public_ip" {
  description = "Public IP address of EC2 Instance"
  value       = aws_instance.MyEC2Instance-Public.*.public_ip
  sensitive   = true
}

#arn of the bucket
output "website_bucket_arn" {
  description = "ARN of the bucket"
  value = module.AWS_S3.arn 
}

# S3 Bucket Name
output "website_bucket_name" {
  description = "Name (id) of the bucket"
  value = module.AWS_S3.name
}

#Subnet
output "Public-Subnet" {
  description = "Public-Subnets"
  value = aws_subnet.Public.id
}

output "Private-Subnet" {
  description = "Private-Subnets"
  value = aws_subnet.Public.id
}