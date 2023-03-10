#!/bin/bash


HealthCheckCode=$(curl  -Li  "$1"  -o /dev/null -w '%{http_code}\n' -s)

echo "$HealthCheckCode"


if [[ "$HealthCheckCode" -eq 200 ]]; then 

   echo "Application is Running"
   exit 0

else 
  
  echo "Application failed to start , please check logs "
  exit 1  
fi 


