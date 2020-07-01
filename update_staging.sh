#!/bin/bash
cd //home/gitlab-runner/env/demo-project/staging/demo-project/
docker-compose -p staging down
git pull
chmod -R 777 etc/
chmod -R 777 backend_addons
chmod -R 777 theme_addons
sed -i 's/27000/37000/g' docker-compose.yml
docker-compose -p staging up -d
