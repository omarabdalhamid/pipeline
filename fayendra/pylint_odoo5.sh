#!/bin/bash

#Flake8 PIPELINE STAG
#invoked on the command-line
#invoked via Python

yellow=`tput setaf 3`
blue=`tput setaf 4`
green=`tput setaf 2`

reset=`tput sgr0`

rm -rf /home/gitlab-runner/pylint/$CI_PROJECT_NAME/$CI_COMMIT_SHORT_SHA
mkdir  -p  /home/gitlab-runner/pylint/$CI_PROJECT_NAME/$CI_COMMIT_SHORT_SHA

cd /home/gitlab-runner/pylint/$CI_PROJECT_NAME/$CI_COMMIT_SHORT_SHA/

git clone https://fayendra:bGwcaaMx8u74AuqDyJRc@gitlab.com/itsys/demo-project.git

cd /home/gitlab-runner/pylint/$CI_PROJECT_NAME/$CI_COMMIT_SHORT_SHA/$CI_PROJECT_NAME/

while IFS= read -r line
do
    echo "$red###################################################\n"
    echo "${yellow} OCA pylint_odoo start test addon : $red line ${reset}\n"
    echo "${blue}###################################################\n"
    echo "${reset}"
     pylint --load-plugins=pylint_odoo -d all -e odoolint ./backend_addons/$line
#     flake8 ./backend_addons/$line
    echo "${blue}###################################################\n"
    echo "${yellow} Flake8 finish test addon :  ${green} $line ${reset}\n"
    echo "${blue}###################################################\n"
    echo "${reset}"

done < ./project_scope

rm -rf /home/gitlab-runner/pylint/$CI_PROJECT_NAME/$CI_COMMIT_SHORT_SHA
