#!/bin/bash

# Update package lists
sudo apt update -y

# Install MicroK8s
sudo snap install microk8s --classic

# Add the current user to the microk8s group
sudo usermod -a -G microk8s $USER

# Change ownership of the .kube directory
sudo chown -f -R $USER ~/.kube

# Alias microk8s and helm commands
echo "alias kubectl='microk8s kubectl'" >> ~/.bashrc
echo "alias helm='microk8s.helm3'" >> ~/.bashrc

# Apply the changes to the current shell session
source ~/.bashrc

# Enable DNS, hostpath-storage, dashboard
microk8s enable dns hostpath-storage dashboard 

# Print completion message
echo "MicroK8s installation and setup complete. Please log out and log back in to apply group changes."

# Check the status of MicroK8s
microk8s status --wait-ready



# Generate a token for accessing the Kubernetes dashboard
echo "To generate an access token, use the following command:"
echo "microk8s kubectl -n kube-system get secret | grep kubernetes-dashboard-token | awk '{print \$1}' | xargs microk8s kubectl -n kube-system describe secret | grep '^token' | awk '{print \$2}'"

# Create YAML for WordPress, MySQL, phpMyAdmin, and TinyFileManager
cat <<EOF > wordpress-setup.yml
apiVersion: v1
kind: Namespace
metadata:
  name: wordpress

---

apiVersion: v1
kind: PersistentVolume
metadata:
  name: wp-pv
  namespace: wordpress
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: /data/wp-pv

---

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: wp-pvc
  namespace: wordpress
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi

---

apiVersion: apps/v1
kind: Deployment
metadata:
  name: wordpress
  namespace: wordpress
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
      - image: wordpress:php7.4
        name: wordpress
        env:
        - name: WORDPRESS_DB_HOST
          value: mysql
        - name: WORDPRESS_DB_USER
          value: wpuser
        - name: WORDPRESS_DB_PASSWORD
          value: password
        - name: WORDPRESS_DB_NAME
          value: wordpress

        - name: MYSQL_ROOT_PASSWORD
          value: rootpassword
        - name: MYSQL_DATABASE
          value: wordpress
        - name: MYSQL_USER
          value: wpuser
        - name: MYSQL_PASSWORD
          value: password
          
        ports:
        - containerPort: 80
        volumeMounts:
        - name: wp-persistent-storage
          mountPath: /var/www/html
      volumes:
      - name: wp-persistent-storage
        persistentVolumeClaim:
          claimName: wp-pvc

---

apiVersion: v1
kind: Service
metadata:
  name: wordpress
  namespace: wordpress
spec:
  type: NodePort
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30100
  selector:
    app: wordpress

---

apiVersion: v1
kind: Service
metadata:
  name: mysql
  namespace: wordpress
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
  namespace: wordpress
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
      - image: mysql:5.7
        name: mysql
        env:
        - name: MYSQL_ROOT_PASSWORD
          value: rootpassword
        - name: MYSQL_DATABASE
          value: wordpress
        - name: MYSQL_USER
          value: wpuser
        - name: MYSQL_PASSWORD
          value: password
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
  namespace: wordpress
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi

---

apiVersion: apps/v1
kind: Deployment
metadata:
  name: phpmyadmin
  namespace: wordpress
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
        - name: PMA_USER
          value: wpuser
        - name: PMA_PASSWORD
          value: password
        ports:
        - containerPort: 80

---

apiVersion: v1
kind: Service
metadata:
  name: phpmyadmin
  namespace: wordpress
spec:
  type: NodePort
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30200   # Specify the desired NodePort value here
  selector:
    app: phpmyadmin

---

apiVersion: apps/v1
kind: Deployment
metadata:
  name: tinyfilemanager
  namespace: wordpress
spec:
  replicas: 1
  selector:
    matchLabels:
      app: tinyfilemanager
  template:
    metadata:
      labels:
        app: tinyfilemanager
    spec:
      containers:
      - image: tinyfilemanager/tinyfilemanager
        name: tinyfilemanager
        env:
        - name: FILE_MANAGER_AUTH
          value: wpuser:password
        ports:
        - containerPort: 80
        volumeMounts:
        - name: wp-persistent-storage
          mountPath: /var/www/html
      volumes:
      - name: wp-persistent-storage
        persistentVolumeClaim:
          claimName: wp-pvc

---

apiVersion: v1
kind: Service
metadata:
  name: tinyfilemanager
  namespace: wordpress
spec:
  type: NodePort
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30300   # Specify the desired NodePort value here
  selector:
    app: tinyfilemanager

EOF

# Apply the WordPress setup YAML
microk8s kubectl apply -f wordpress-setup.yml


