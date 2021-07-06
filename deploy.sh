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
echo "Adding tags"
VOLTRG=`terraform output -json auto_tag | jq -r .volt_group`
TAGS=`terraform output -json auto_tag | jq -r .tags | tr -d '"{},' | sed 's/: /=/g'`
az group update --resource-group $VOLTRG --tags $TAGS -o none
echo "Operation Completed at $now, after $duration seconds"
