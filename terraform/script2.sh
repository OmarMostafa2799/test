#!/bin/bash
sudo yum update -y
sudo yum install -y httpd
sudo systemctl start httpd
sudo systemctl enable httpd

echo "Hello DevOps Track From Private EC2" | sudo tee /var/www/html/index.html > /dev/null
cat /var/www/html/index.html

sudo systemctl restart httpd

