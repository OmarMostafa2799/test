#!/bin/bash


PRIVATE_EC2_IP="10.0.2.92"  # Replace with your private EC2 IP
PORT="8080"                 # Replace with port want to listen on this use in outside curl

sudo mkdir -p /etc/nginx/conf.d
sudo touch /etc/nginx/conf.d/reverse-proxy.conf
NGINX_CONF_PATH="/etc/nginx/conf.d/reverse-proxy.conf"

sudo bash -c "cat > $NGINX_CONF_PATH" <<EOF
server {
    listen ${PORT};

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
sudo setsebool -P httpd_can_network_relay on
sudo systemctl restart nginx


echo "Test locally with: curl -i http://localhost:${PORT}"
