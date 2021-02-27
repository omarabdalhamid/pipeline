#!/bin/bash

rm -rf /home/gitlab-runner/artifact/*

mkdir -p  /home/gitlab-runner/artifact/$CI_COMMIT_SHORT_SHA

cd /home/gitlab-runner/artifact/$CI_COMMIT_SHORT_SHA/

git clone git@gitlab.com:fayendra/Fayendra.git

cd Fayendra 
