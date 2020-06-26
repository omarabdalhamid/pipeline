#!/bin/bash
yum install git -y
curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.rpm.sh | sudo bash
yum install gitlab-runner -y
yum list gitlab-runner --showduplicates | sort -r
