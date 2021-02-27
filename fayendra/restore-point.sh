#!/bin/bash

rm -rf /home/gitlab-runner/restore-point/*

mkdir -p  /home/gitlab-runner/restore-point/$CI_COMMIT_SHORT_SHA

mkdir -p  /home/gitlab-runner/restore-point/$CI_COMMIT_SHORT_SHA/current-point

mkdir -p  /home/gitlab-runner/restore-point/$CI_COMMIT_SHORT_SHA/restore-point

cd /home/gitlab-runner/restore-point/$CI_COMMIT_SHORT_SHA/current-point/

git clone git@gitlab.com:fayendra/Fayendra.git

rm -rf /home/gitlab-runner/restore-point/$CI_COMMIT_SHORT_SHA/current-point/Fayendra/*

cd  /home/gitlab-runner/restore-point/$CI_COMMIT_SHORT_SHA/restore-point/

git clone git@gitlab.com:fayendra/Fayendra.git

cd Fayendra 

git checkout $CI_COMMIT_SHORT_SHA

cp -vr /home/gitlab-runner/restore-point/$CI_COMMIT_SHORT_SHA/restore-point/Fayendra/* /home/gitlab-runner/restore-point/$CI_COMMIT_SHORT_SHA/current-point/Fayendra/

cd /home/gitlab-runner/restore-point/$CI_COMMIT_SHORT_SHA/current-point/Fayendra/ 

git add .

git commit -am " Recovery to point $CI_COMMIT_SHORT_SHA"

git push 

rm -rf /home/gitlab-runner/restore-point/*
