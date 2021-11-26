#! /bin/bash
sudo yum update -y
sudo yum install httpd -y
sudo service httpd start -y
echo "<h1>Welcome to new ec2 instance</h1>"