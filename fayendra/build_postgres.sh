#!/bin/bash
docker system prune -f 
#rm -rf /home/gitlab-runner/pipeline/branch/$CI_COMMIT_SHORT_SHA
#mkdir /home/gitlab-runner/pipeline/branch/$CI_COMMIT_SHORT_SHA
#cd  /home/gitlab-runner/pipeline/branch/$CI_COMMIT_SHORT_SHA
#git clone https://fayendra:bGwcaaMx8u74AuqDyJRc@gitlab.com/itsys/demo-project.git 
#cd $CI_PROJECT_NAME
#git checkout $CI_COMMIT_REF_NAME
#cd docker
docker pull postgres:11.7

#docker build . -t odoo-app:$CI_COMMIT_SHORT_SHA
#rm -rf /home/gitlab-runner/pipeline/branch/$CI_COMMIT_SHORT_SHA

docker system prune -f 
