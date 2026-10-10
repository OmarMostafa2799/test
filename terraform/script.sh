#!/bin/bash
sudo yum update -y
sudo yum install -y nginx
sudo useradd --system --no-create-home --shell /sbin/nologin nginx
sudo systemctl start nginx
sudo systemctl enable nginx
