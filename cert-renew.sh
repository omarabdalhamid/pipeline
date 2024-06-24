#!/bin/bash

# Navigate to the directory containing the NGINX configuration files
#cd /etc/nginx/sites-enabled/

# Get a list of all configuration files
ls /etc/nginx/sites-enabled/ > domain_scope

# Loop through each configuration file
while IFS= read -r domain
do

        echo "Renewing SSL certificate for domain: $domain"
        certbot certonly  --force-renewal --nginx   -d  $domain
        echo "SSL certificate renewed for domain: $domain"
        echo "---------------------------------------------"

done < ./domain_scope
