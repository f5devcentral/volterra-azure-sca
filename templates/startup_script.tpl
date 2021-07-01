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
      type: inline
      value: ${application_services}
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
