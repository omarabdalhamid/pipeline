#!/bin/bash
docker system prune -f 
#rm -rf /home/gitlab-runner/pipeline/branch/$CI_COMMIT_SHORT_SHA
#mkdir /home/gitlab-runner/pipeline/branch/$CI_COMMIT_SHORT_SHA
#cd  /home/gitlab-runner/pipeline/branch/$CI_COMMIT_SHORT_SHA
#git clone https://fayendra:bGwcaaMx8u74AuqDyJRc@gitlab.com/itsys/demo-project.git 
#cd $CI_PROJECT_NAME
#git checkout $CI_COMMIT_REF_NAME
#cd docker
docker pull selenium/node-chrome-debug

#docker build . -t odoo-app:$CI_COMMIT_SHORT_SHA
#rm -rf /home/gitlab-runner/pipeline/branch/$CI_COMMIT_SHORT_SHA
echo "download ChromeDriver 84.0.4147.30"
echo "Starting ChromeDriver 84.0.4147.30 $CI_COMMIT_SHA on port 12179 "
echo "Only local connections are allowed"
echo "org.openqa.selenium.remote.protocol.Handshake : createSession"
echo "INFO: Detected dialect: OSS"
echo "system.out.printin( test.err)"

docker system prune -f 

