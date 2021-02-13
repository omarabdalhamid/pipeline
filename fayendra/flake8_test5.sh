#!/bin/bash

#Flake8 PIPELINE STAG
#invoked on the command-line
#invoked via Python

rm -rf /home/gitlab-runner/builds/Lxsoe-ry/0/*

rm -rf /home/gitlab-runner/flake8/$CI_PROJECT_NAME/$CI_COMMIT_SHORT_SHA
mkdir  -p  /home/gitlab-runner/flake8/$CI_PROJECT_NAME/$CI_COMMIT_SHORT_SHA

cd /home/gitlab-runner/flake8/$CI_PROJECT_NAME/$CI_COMMIT_SHORT_SHA/

git clone https://fayendra:bGwcaaMx8u74AuqDyJRc@gitlab.com/fayendra/Fayendra.git


cd /home/gitlab-runner/flake8/$CI_PROJECT_NAME/$CI_COMMIT_SHORT_SHA/$CI_PROJECT_NAME/

while IFS= read -r line
do
    echo "${blue}###################################################\n"
    echo "${yellow} OCA pylint_odoo start test addon : ${green} $line ${reset}\n"
    echo "${blue}###################################################\n"
    echo "${reset}"
#    pylint3 --load-plugins=pylint_odoo -d all -e odoolint ./itsys_addons/$line
     flake8 ./backend_addons/$line
    echo "${blue}###################################################\n"
    echo "${yellow} Flake8 finish test addon :  ${green} $line ${reset}\n"
    echo "${blue}###################################################\n"
    echo "${reset}"

done < ./project_scope

rm -rf /home/gitlab-runner/flake8/$CI_PROJECT_NAME/$CI_COMMIT_SHORT_SHA
