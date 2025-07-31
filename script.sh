#!/bin/bash
sudo yum update -y
sudo yum install -y httpd
echo "Welcome to Auto Scaling Demo From Scaling Machine!" | sudo tee /var/www/html/index.html
sudo systemctl start httpd
sudo systemctl enable httpd