#Instance Public IP as output
output "ec2_instance_public_ip" {
  description = "Public IP address of EC2 Instance"
  value       = aws_instance.MyEC2Instance.*.public_ip
  sensitive   = true
}