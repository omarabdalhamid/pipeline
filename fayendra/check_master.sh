#!/bin/bash
rm -rf /home/gitlab-runner/pipeline/branch/$CI_COMMIT_SHORT_SHA
mkdir /home/gitlab-runner/pipeline/branch/$CI_COMMIT_SHORT_SHA
cd  /home/gitlab-runner/pipeline/branch/$CI_COMMIT_SHORT_SHA
git clone https://fayendra:bGwcaaMx8u74AuqDyJRc@gitlab.com/fayendra/Fayendra.git 
cd $CI_PROJECT_NAME
git checkout $CI_COMMIT_REF_NAME
git rev-list HEAD > check_master.txt 
remote_master_sha=$(git ls-remote https://fayendra:bGwcaaMx8u74AuqDyJRc@gitlab.com/fayendra/Fayendra.git HEAD | awk '{ print $1}')


if grep -Fxq "$remote_master_sha"  ./check_master.txt
then
    echo "Master Merged Successfully"
    exit 0
else
    echo "Please merger master before push to your branch"
    exit 1 
fi
