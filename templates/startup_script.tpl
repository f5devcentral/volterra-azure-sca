#!/bin/bash

# Send output to log file and serial console
mkdir -p  /var/log/cloud /config/cloud /var/config/rest/downloads
LOG_FILE=/var/log/cloud/startup-script.log
[[ ! -f $LOG_FILE ]] && touch $LOG_FILE || { echo "Run Only Once. Exiting"; exit; }
npipe=/tmp/$.tmp
trap "rm -f $npipe" EXIT
mknod $npipe p
tee <$npipe -a $LOG_FILE /dev/ttyS0 &
exec 1>&-
exec 1>$npipe
exec 2>&1

# wait bigip
source /usr/lib/bigstart/bigip-ready-functions
wait_bigip_ready

# fix networks, for some reason the metric gets all whacked
# metadata route
echo  -e 'create cli transaction;
modify sys db config.allow.rfc3927 value enable;
create sys management-route metadata-route network 169.254.169.254/32 gateway ${mgmtGateway};
submit cli transaction' | tmsh -q
route add -net default gw ${mgmtGateway} netmask 0.0.0.0 dev mgmt metric 0

### redo as3
# Vinnie make fix.  @Vinnie357 forever
local_host="http://localhost:8100"

as3Url="/mgmt/shared/appsvcs/declare"
as3CheckUrl="/mgmt/shared/appsvcs/info"
as3TaskUrl="/mgmt/shared/appsvcs/task/"

cat > /config/as3.json <<EOF
${application_services}
EOF
externalVip=$(curl -sf --retry 20 -H Metadata:true "http://169.254.169.254/metadata/instance/network/interface?api-version=2017-08-01" | jq -r '.[1].ipv4.ipAddress[1].privateIpAddress')
sed -i "s/-external-virtual-address-/$externalVip/g" /config/as3.json

cat << 'EOF' > /config/cloud/runtime-init-conf.yaml
runtime_parameters: []
  # - name: ADMIN_PASS
  #   type: secret
  #   secretProvider:
  #     environment: azure
  #     type: KeyVault
  #     vaultUrl: ${keyvault_uri}
  #     secretId: ${secret_id}
  #     field: password
pre_onboard_enabled:
  - name: provision_rest
    type: inline
    commands:
      - /usr/bin/setdb provision.extramb 500
      - /usr/bin/setdb restjavad.useextramb true
      - /usr/bin/setdb setup.run false
extension_packages:
  install_operations:
    - extensionType: do
      extensionVersion: 1.20.0
    - extensionType: as3
      extensionVersion: 3.29.0
    - extensionType: fast
      extensionVersion: 1.8.0
    - extensionType: ts
      extensionVersion: 1.19.0
extension_services:
  service_operations:
    - extensionType: do
      type: inline
      value: ${declative_onboarding}
    - extensionType: as3
      type: url
      value: file:///config/as3.json
post_onboard_enabled: []
EOF

### runcmd:
# Download
PACKAGE="f5-bigip-runtime-init-1.2.1-1.gz.run"
PACKAGE_URL="https://cdn.f5.com/product/cloudsolutions/f5-bigip-runtime-init/v1.2.1/dist/$PACKAGE"
for i in {1..30}; do
    curl -fv --retry 1 --connect-timeout 5 -L $PACKAGE_URL -o /var/config/rest/downloads/$PACKAGE && break || sleep 10
done

admin_username='${uname}'
admin_password='${upassword}'
CREDS="$admin_username:$admin_password"

waitActive () {
checks=0
while [[ "$checks" -lt 30 ]]; do
    tmsh -a show sys ready | grep -q no
   if [ $? == 1 ]; then
       echo "[INFO: system ready]"
       break
   fi
   echo "[WARN: system not ready yet count: $checks]"
   tmsh -a show sys ready | grep no
   let checks=checks+1
   sleep 10
done
}

function checkAS3() {
    # Check AS3 Ready
    count=0
    while [ $count -le 4 ]
    do
    #as3Status=$(curl -i -u "$CREDS" $local_host$as3CheckUrl | grep HTTP | awk '{print $2}')
    as3Status=$(restcurl -u "$CREDS" -X GET $as3CheckUrl | jq -r .code)
    if  [ "$as3Status" == "null" ] || [ -z "$as3Status" ]; then
        type=$(restcurl -u "$CREDS" -X GET $as3CheckUrl | jq -r type )
        if [ "$type" == "object" ]; then
            as3Status="200"
        fi
    fi
    if [[ $as3Status == "200" ]]; then
        version=$(restcurl -u "$CREDS" -X GET $as3CheckUrl | jq -r .version)
        echo "As3 $version online "
        break
    elif [[ $as3Status == "404" ]]; then
        echo "AS3 Status $as3Status"
        bigstart restart restnoded
        sleep 30
        bigstart status restnoded | grep running
        status=$?
        echo "restnoded:$status"
    else
        echo "AS3 Status $as3Status"
        count=$[$count+1]
    fi
    sleep 10
    done
}
function runAS3 () {
    count=0
    while [ $count -le 4 ]
        do
            # wait for do to finish
            waitActive
            # make task
            task=$(curl -s -u $CREDS -H "Content-Type: Application/json" -H 'Expect:' -X POST $local_host$as3Url?async=true -d @/config/as3.json | jq -r .id)
            echo "===== starting as3 task: $task ====="
            sleep 1
            count=$[$count+1]
            # check task code
            taskCount=0
        while [ $taskCount -le 3 ]
        do
            as3CodeType=$(curl -s -u $CREDS -X GET $local_host$as3TaskUrl/$task | jq -r type )
            if [[ "$as3CodeType" == "object" ]]; then
                code=$(curl -s -u $CREDS -X GET $local_host$as3TaskUrl/$task | jq -r .)
                tenants=$(curl -s -u $CREDS -X GET $local_host$as3TaskUrl/$task | jq -r .results[].tenant)
                echo "object: $code"
            elif [ "$as3CodeType" == "array" ]; then
                echo "array $code check task, breaking"
                break
            else
                echo "unknown type:$as3CodeType"
            fi
            sleep 1
            if jq -e . >/dev/null 2>&1 <<<"$code"; then
                echo "Parsed JSON successfully and got something other than false/null"
                status=$(curl -s -u $CREDS $local_host$as3TaskUrl/$task | jq -r  .items[].results[].message)
                case $status in
                *progress)
                    # in progress
                    echo -e "Running: $task status: $status tenants: $tenants count: $taskCount "
                    sleep 120
                    taskCount=$[$taskCount+1]
                    ;;
                *Error*)
                    # error
                    echo -e "Error Task: $task status: $status tenants: $tenants "
                    if [[ "$status" = *"progress"* ]]; then
                        sleep 180
                        break
                    else
                        break
                    fi
                    ;;
                *failed*)
                    # failed
                    echo -e "failed: $task status: $status tenants: $tenants "
                    break
                    ;;
                *success*)
                    # successful!
                    echo -e "success: $task status: $status tenants: $tenants "
                    break 3
                    ;;
                no*change)
                    # finished
                    echo -e "no change: $task status: $status tenants: $tenants "
                    break 4
                    ;;
                *)
                # other
                echo "status: $status"
                debug=$(curl -s -u $CREDS $local_host$as3TaskUrl/$task)
                echo "debug: $debug"
                error=$(curl -s -u $CREDS $local_host$as3TaskUrl/$task | jq -r '.results[].message')
                echo "Other: $task, $error"
                break
                ;;
                esac
            else
                echo "Failed to parse JSON, or got false/null"
                echo "AS3 status code: $code"
                debug=$(curl -s -u $CREDS $local_host$doTaskUrl/$task)
                echo "debug AS3 code: $debug"
                count=$[$count+1]
            fi
        done
    done
}



# Install
bash /var/config/rest/downloads/f5-bigip-runtime-init-1.2.1-1.gz.run -- "--cloud azure"
# Run
f5-bigip-runtime-init --config-file /config/cloud/runtime-init-conf.yaml

#  run as3
count=0
while [ $count -le 4 ]
do
    as3Status=$(checkAS3)
    echo "AS3 check status: $as3Status"
    if [[ "$as3Status" == *"online"* ]]; then
            echo "running as3: $as3Status"
            runAS3
            echo "done with AS3"
            results=$(restcurl -u $CREDS $as3TaskUrl | jq '.items[] | .id, .results')
            echo "AS3 results: $results"
            break
    elif [ $count -le 2 ]; then
        echo "Status code: $as3Status  AS3 not ready yet..."
        count=$[$count+1]
    else
        echo "AS3 API Status $as3Status"
        break
    fi
done

# add default route now that everything is good
# hard coded right now, fix later
tmsh create net route volterra network 0.0.0.0/0 gw 10.90.2.5;
