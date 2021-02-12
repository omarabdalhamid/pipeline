#!/bin/bash
cd  /home/gitlab-runner/env/demo-project/staging/demo-project/
docker-compose  down
git pull
chmod -R 777 etc/
chmod -R 777 backend_addons
chmod -R 777 theme_addons
docker-compose  up -d
