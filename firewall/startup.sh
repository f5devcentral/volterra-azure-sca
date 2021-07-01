#!/bin/bash

mkdir -p /config/cloud
cat << 'EOF' > /config/cloud/runtime-init-conf.yaml
---
runtime_parameters:
  - name: ADMIN_PASS
    type: secret
    secretProvider:
      environment: azure
      type: KeyVault
      vaultUrl: https://ecbad9f1-vault.vault.azure.net/
      secretId: https://ecbad9f1-vault.vault.azure.net/secrets/szechuan/8299270089a748ada5e33a448fb968dc
      field: password
pre_onboard_enabled:
  - name: provision_rest
    type: inline
    commands:
      - /usr/bin/setdb provision.extramb 500
      - /usr/bin/setdb restjavad.useextramb true
bigip_ready_enabled:
  - name: set_message_size
    type: inline
    commands:
      - '/usr/bin/curl -s -f -u admin: -H "Content-Type: application/json" -d ''{"maxMessageBodySize":134217728}''
        -X POST http://localhost:8100/mgmt/shared/server/messaging/settings/8100 |
        jq .'
      - f5mku -r {{{ ADMIN_PASS }}}
  - name: reset_master_key
    type: inline
    commands:
      - f5mku -r {{{ ADMIN_PASS }}}
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
#extension_services:
#  service_operations:
#    - extensionType: do
#      type: url
#      value: https://raw.githubusercontent.com/F5Networks/f5-bigip-runtime-init/main/examples/declarations/do_w_admin.json
#    - extensionType: as3
#      type: url
#      value: https://raw.githubusercontent.com/F5Networks/f5-bigip-runtime-init/main/examples/declarations/as3.json
      
EOF

curl https://cdn.f5.com/product/cloudsolutions/f5-bigip-runtime-init/v1.2.1/dist/f5-bigip-runtime-init-1.2.1-1.gz.run -o f5-bigip-runtime-init-1.2.1-1.gz.run && bash f5-bigip-runtime-init-1.2.1-1.gz.run -- '--cloud azure'

f5-bigip-runtime-init --config-file /config/cloud/runtime-init-conf.yaml
