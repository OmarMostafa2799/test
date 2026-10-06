#!/bin/bash


PRIVATE_EC2_IP="10.0.1.236"  # Replace with your private EC2 IP
NGINX_CONF_PATH="/etc/nginx/conf.d/reverse-proxy.conf"

sudo bash -c "cat > $NGINX_CONF_PATH" <<EOF
server {
    listen 80;

    server_name _;  

    location / {
        proxy_pass http://$PRIVATE_EC2_IP:80;  # Forward to private EC2 IP
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF


sudo chmod 644 $NGINX_CONF_PATH
sudo systemctl restart nginx

