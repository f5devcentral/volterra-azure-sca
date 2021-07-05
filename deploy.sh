#!/bin/bash
set -e
start=$SECONDS
terraform init
terraform fmt
terraform validate
terraform plan
# apply
read -p "Press enter to continue"
terraform apply --auto-approve
duration=$(( SECONDS - start ))
now=$(date +"%T")
echo "Operation Completed at $now, after $duration seconds"
