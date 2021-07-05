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

# fix networks, for some reason the metric gets all whacked
# metadata route
echo  -e 'create cli transaction;
modify sys db config.allow.rfc3927 value enable;
create sys management-route metadata-route network 169.254.169.254/32 gateway ${mgmtGateway};
submit cli transaction' | tmsh -q
route add -net default gw ${mgmtGateway} netmask 0.0.0.0 dev mgmt metric 0

### redo as3
# Vinnie make fix.  @Vinnie357 forever
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
      extensionVersion: 3.27.0
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

# Install
bash /var/config/rest/downloads/f5-bigip-runtime-init-1.2.1-1.gz.run -- "--cloud azure"
# Run
f5-bigip-runtime-init --config-file /config/cloud/runtime-init-conf.yaml
