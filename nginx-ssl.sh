#!/bin/bash

# Variables for domain names
# Kubernetes dashboard domain port 3100
DOMAIN1="example1.com"  
PORT1=31000
# Wordpress nginx domain  port 30100
DOMAIN2="example2.com"
PORT2=30100
# Phpmyadmin nginx domain port 30200
DOMAIN3="example3.com"
PORT3=30200
#tiny File manager nginx domain  port 30300
DOMAIN3="example4.com"
PORT4=3033

# Update package list and install Nginx
sudo apt update -y
sudo apt install -y nginx

# Install Certbot and the Nginx plugin
sudo apt install -y certbot python3-certbot-nginx

# Remove the default Nginx configuration file
sudo rm -rf /etc/nginx/sites-available/default
sudo rm -rf /etc/nginx/sites-enabled/default


# Function to create Nginx configuration file for a domain and port
create_nginx_conf() {
  local DOMAIN=$1
  local PORT=$2
  cat <<EOF | sudo tee /etc/nginx/sites-available/$DOMAIN
server {
   server_name $DOMAIN;
   if (\$http_x_forwarded_proto = 'http'){
     return 301 https://\$host\$request_uri;
    }

#     add_header 'Access-Control-Allow-Origin' '*' always;
 access_log /var/log/nginx/access.log;
 error_log /var/log/nginx/error.log;
 proxy_buffers 16 64k;
 proxy_buffer_size 128k;
 client_max_body_size 4000M;
 gzip on;
 gzip_disable "msie6";
 gzip_vary on;
 gzip_proxied any;
 gzip_comp_level 6;
 gzip_http_version 1.1;
 gzip_min_length 256;
 gzip_types
 text/css
 text/javascript
 text/xml
 text/plain
 image/bmp
 image/gif
 image/jpeg
 image/jpg
  image/png
  image/svg+xml
  image/x-icon
  application/javascript
  application/json
  application/rss+xml
  application/vnd.ms-fontobject
  application/x-font-ttf
  application/x-javascript
  application/xml
  application/xml+rss;

 location / {
 proxy_connect_timeout 400000000s;
 proxy_send_timeout 400000000s;
 proxy_read_timeout 400000000s;
 proxy_pass  http://127.0.0.1:$PORT;
 proxy_set_header Host \$host;
 proxy_set_header X-Forwarded-Host \$host;
 proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
 proxy_set_header X-Forwarded-Proto \$scheme;
 proxy_set_header X-Real-IP \$remote_addr;
 proxy_redirect off;
 }







    listen 443 ssl; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem; # managed by Certbot
#    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
#    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot
}

server {
    if ($host = $DOMAIN) {
        return 301 https://\$host\$request_uri;
    } # managed by Certbot

   server_name $DOMAIN;
    listen 80;
    return 404; # managed by Certbot

}
EOF

  # Enable the configuration by creating a symbolic link to the sites-enabled directory
  sudo ln -s /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/$DOMAIN
}

# Create Nginx configuration files for the domains
create_nginx_conf $DOMAIN1 $PORT1
create_nginx_conf $DOMAIN2 $PORT2
create_nginx_conf $DOMAIN3 $PORT3

# Test Nginx configuration
sudo nginx -t

# Reload Nginx to apply changes
sudo systemctl reload nginx

# Obtain SSL certificates for the domains using Certbot
for DOMAIN in $DOMAIN1 $DOMAIN2 $DOMAIN3
do
    sudo certbot --nginx -d $DOMAIN
done

# Reload Nginx to apply SSL certificates
sudo systemctl reload nginx

echo "Nginx and Certbot installation and configuration complete."
