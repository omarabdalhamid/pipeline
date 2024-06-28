#!/bin/bash
# Create YAML for WordPress, MySQL, phpMyAdmin, and TinyFileManager

clientid=$1
DOMAIN=$2


#!/bin/bash
# Define the characters allowed in the password
allowed_chars="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
allowed_chars_root="ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz"
allowed_chars_tinyfm="AVASBAJSAQPKQSMKQLDM1QJBQSAKJQNDO9IDQB7QJBQ4JLB3DQDBQSOQIQUWYTRFVVNMPLMAQW"

# Define the password length
password_length=16

# Generate the password
passowrd="wBi0"
for i in $(seq 1 $password_length); do
      dbpassword="${password}${allowed_chars:$(($RANDOM % ${#allowed_chars})):8}"
      dbrootpassword="${password}${allowed_chars_root:$(($RANDOM % ${#allowed_chars_root})):16}"
      tinyfm_prefix="${password}${allowed_chars_tinyfm:$(($RANDOM % ${#allowed_chars_tinyfm})):16}"
done


cat <<EOF > $clientid.yml


apiVersion: v1
kind: Namespace
metadata:
  name: $clientid

---

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: wp-pvc
  namespace: $clientid
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 20Gi
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: php-ini-config
  namespace: $clientid
data:
  custom-php.ini: |
    upload_max_filesize = 640M
    post_max_size = 640M
    max_execution_time = 6000
    max_input_time = 3000
    memory_limit = 2560M

      

---

apiVersion: apps/v1
kind: Deployment
metadata:
  name: wordpress
  namespace: $clientid
spec:
  replicas: 1
  selector:
    matchLabels:
      app: wordpress
  template:
    metadata:
      labels:
        app: wordpress
    spec:
      containers:
      - image: omarabdalhamid/wordpress-tinyfm:php-fm.7.4
        lifecycle:
           postStart:
             exec:
               command: ["/bin/sh", "-c", "mkdir /var/www/html/$tinyfm_prefix &&  cp -vr /var/www/tinfm.php /var/www/html/$tinyfm_prefix/index.php"]
        name: wordpress
        env:
        - name: WORDPRESS_DB_HOST
          value: mysql
        - name: WORDPRESS_DB_USER
          value: wpuser
        - name: WORDPRESS_DB_PASSWORD
          value: $dbpassword
        - name: WORDPRESS_DB_NAME
          value: wordpress          
        ports:
        - containerPort: 80
        volumeMounts:
        - name: wp-persistent-storage
          mountPath: /var/www/html
        - name: php-ini
          mountPath: /usr/local/etc/php/conf.d/custom-php.ini
          subPath: custom-php.ini          
      volumes:
      - name: wp-persistent-storage
        persistentVolumeClaim:
          claimName: wp-pvc
      - name: php-ini
        configMap:
          name: php-ini-config
---

apiVersion: v1
kind: Service
metadata:
  name: wordpress
  namespace: $clientid
spec:
  type: ClusterIP
  ports:
  - port: 80
    targetPort: 80
  selector:
    app: wordpress

---

apiVersion: v1
kind: Service
metadata:
  name: mysql
  namespace: $clientid
spec:
  selector:
    app: mysql
  ports:
    - protocol: TCP
      port: 3306
---

apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysql
  namespace: $clientid
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
      - image: mysql:8.0
        name: mysql
        env:
        - name: MYSQL_ROOT_PASSWORD
          value: $dbrootpassword
        - name: MYSQL_DATABASE
          value: wordpress
        - name: MYSQL_USER
          value: wpuser
        - name: MYSQL_PASSWORD
          value: $dbpassword
        ports:
        - containerPort: 3306
        volumeMounts:
        - name: mysql-persistent-storage
          mountPath: /var/lib/mysql
      volumes:
      - name: mysql-persistent-storage
        persistentVolumeClaim:
          claimName: mysql-pvc

---

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-pvc
  namespace: $clientid
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 20Gi

---

apiVersion: apps/v1
kind: Deployment
metadata:
  name: phpmyadmin
  namespace: $clientid
spec:
  replicas: 1
  selector:
    matchLabels:
      app: phpmyadmin
  template:
    metadata:
      labels:
        app: phpmyadmin
    spec:
      containers:
      - image: phpmyadmin/phpmyadmin
        name: phpmyadmin
        env:
        - name: PMA_HOST
          value: mysql
        ports:
        - containerPort: 80

---

apiVersion: v1
kind: Service
metadata:
  name: phpmyadmin
  namespace: $clientid
spec:
  type: ClusterIP
  ports:
  - port: 80
    targetPort: 80
  selector:
    app: phpmyadmin

EOF

# Apply the WordPress setup YAML

microk8s kubectl apply -f $clientid.yml
sleep 10s

wp_cluster_ip=$(microk8s kubectl get service -n "$clientid" wordpress -o jsonpath='{.spec.clusterIP}')
#tinyfm_cluster_ip=$(microk8s kubectl get service -n "$clientid" tinyfilemanager -o jsonpath='{.spec.clusterIP}')


#### Configure Nginx with ssl cert
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
 proxy_pass  http://$wp_cluster_ip;
 proxy_set_header Host \$host;
 proxy_set_header X-Forwarded-Host \$host;
 proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
 proxy_set_header X-Forwarded-Proto \$scheme;
 proxy_set_header X-Real-IP \$remote_addr;
 proxy_redirect off;
 }

 location /$tinyfm_prefix {
 proxy_connect_timeout 400000000s;
 proxy_send_timeout 400000000s;
 proxy_read_timeout 400000000s;
 proxy_pass  http://$wp_cluster_ip/$tinyfm_prefix/;
 proxy_set_header Host \$host;
 proxy_set_header X-Forwarded-Host \$host;
 proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
 proxy_set_header X-Forwarded-Proto \$scheme;
 proxy_set_header X-Real-IP \$remote_addr;
 proxy_redirect off;
 }

#    listen 443 ssl; # managed by Certbot
#    ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem; # managed by Certbot
#    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem; # managed by Certbot
#    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
#    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot
}

server {
    if (\$host = $DOMAIN) {
        return 301 https://\$host\$request_uri;
    } # managed by Certbot

   server_name $DOMAIN;
    listen 80;
    return 404; # managed by Certbot

}
EOF

ln -s /etc/nginx/sites-available/$DOMAIN  /etc/nginx/sites-enabled/$DOMAIN

sudo certbot --nginx -d $DOMAIN

sudo systemctl reload nginx



echo "=============================================================="

echo "Wordpress URL : https://$DOMAIN"

echo "=============================================================="

echo "Wordpress DB Root Password : $dbrootpassword"

echo "=============================================================="

echo  "Wordpress DB  Password : $dbpassword"

echo "=============================================================="

echo "Tiny File manager URL : https://$DOMAIN/$tinyfm_prefix"

echo "=============================================================="

echo "Tiny File manager admin user   :  admin"
echo "Tiny File manager admin user   :  548b48db88"

echo "=============================================================="

echo "Tiny File manager admin user   :  user"
echo "Tiny File manager admin user   :  64974f4d7b"

echo "=============================================================="
