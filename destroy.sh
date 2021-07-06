#!/bin/bash
#adding workaround for destroy dependencies
DELRG=`terraform output -json auto_tag | jq -r .resource_group`
##
echo "destroying demo"
read -r -p "Are you sure? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
then
    terraform destroy --auto-approve
    az group delete --name $DELRG --yes
    terraform destroy --auto-approve
    # while [ $? -ne 0 ]; do
    #     az group delete --name $DELRG --yes
    #     terraform destroy --auto-approve
    # done
else
    echo "canceling"
fi
