#!/bin/bash
mkdir /home/gitlab-runner/pipeline/branch/$CI_COMMIT_SHORT_SHA
cd  /home/gitlab-runner/pipeline/branch/$CI_COMMIT_SHORT_SHA
git clone https://ibnabbas:5C_3Fk1MWCXsrry8djD6@gitlab.com/ibnabbas/ibn-abbas.git --branch $CI_COMMIT_REF_NAME
cd $CI_PROJECT_NAME
remote_master_sha=$(git ls-remote https://ibnabbas:5C_3Fk1MWCXsrry8djD6@gitlab.com/ibnabbas/ibn-abbas.git HEAD | awk '{ print $1}')
local_master_sha=$(git rev-parse HEAD)
echo $remote_master_sha
echo $local_master_sha

if [ "$remote_master_sha" = "$local_master_sha" ]
then 
  echo "Master Updated"
#  exit 0 
else
  echo "Please Merge last master into your branch"
#  exit 1
fi 
