#!/bin/bash
#bk-name = echo $(date '+%A-%B-%d-%Y-%H-%M')
mkdir -p  /clone-fayendra/
rm -rf /clone-fayendra/*
cd  /clone-fayendra/
git clone https://fayendra:bGwcaaMx8u74AuqDyJRc@gitlab.com/fayendra/Fayendra.git
mkdir -p  /backup/"$(date '+%A-%B-%d-%Y-%H-%M')"
mkdir -p /backup/rollback
cp -vr /backup/rollback /backup/"$(date '+%A-%B-%d-%Y-%H-%M')"
rm -rf /backup/rollback/* 
cp -vr /odoo/custom/addons/fayendra /backup/rollback/
rm -rf /odoo/custom/addons/fayendra/*
cp -vr /clone-fayendra/Fayendra/backend_addons/* /odoo/custom/addons/fayendra/

chown -R  odoo:odoo /odoo/custom/addons/fayendra/

service odoo-server restart

function checkIt(){
service odoo-server status | grep 'running' &> /dev/null
if [ $? == 0 ]; then
   echo $1" service is running";
 else
   service odoo-server restart
 fi;
}

checkIt "odoo-server"
checkIt "odoo-server"
checkIt "odoo-server"

