# Volterra Azure Secure Cloud Gateway (SCA/SCG)
Volterra version of SCA/SCCA/SACA

<!--TOC-->

- [Volterra Azure Secure Cloud Gateway (SCA/SCG)](#volterra-azure-secure-cloud-gateway-scascg)
  - [To do](#to-do)
  - [Requirements](#requirements)
  - [Providers](#providers)
  - [Modules](#modules)
  - [Resources](#resources)
  - [Inputs](#inputs)
  - [Outputs](#outputs)
  - [Deployment](#deployment)
  - [Troubleshooting](#troubleshooting)

<!--TOC-->

## To do

- hardcoded IP values for testing, fix.
- flip elastic transport to tcp vs http
- flip logstash_beats to tcp vs http
- mgmt partition is leftover from SACA, can destroy.
- Azure Key Vaults takes 2m to provision. "module.azure.azurerm_key_vault.keyvault: Creation complete after 2m5s"
  - Doesnt work with runtime-init for some reason, troubleshoot later.

![Rough Diagram](/images/sce-azure.png)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 2.30.0 |
| <a name="requirement_http"></a> [http](#requirement\_http) | 2.1.0 |
| <a name="requirement_volterrarm"></a> [volterrarm](#requirement\_volterrarm) | 0.7.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_util"></a> [util](#module\_util) | ./util | n/a |
| <a name="module_azure"></a> [azure](#module\_azure) | ./azure | n/a |
| <a name="module_volterra"></a> [volterra](#module\_volterra) | ./volterra | n/a |
| <a name="module_firewall"></a> [firewall](#module\_firewall) | ./firewall | n/a |
| <a name="module_applications"></a> [applications](#module\_applications) | ./applications | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| <a name="input_tenant_name"></a> [tenant\_name](#input\_tenant\_name) | REQUIRED:  This is your Volterra Tenant Name:  https://<tenant\_name>.console.ves.volterra.io/api | `string` | `"f5-sa"` |
| <a name="input_adminUserName"></a> [adminUserName](#input\_adminUserName) | REQUIRED: Admin Username for All systems | `string` | `"xadmin"` |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | REQUIRED:  This is your Volterra Namespace | `string` | `"m-coleman"` |
| <a name="input_api_cert"></a> [api\_cert](#input\_api\_cert) | REQUIRED:  This is the path to the Volterra API Key.  See https://volterra.io/docs/how-to/user-mgmt/credentials | `string` | `"./creds/api2.cer"` |
| <a name="input_location"></a> [location](#input\_location) | REQUIRED: Azure Region: usgovvirginia, usgovarizona, etc. For a list of available locations for your subscription use `az account list-locations -o table` | `string` | `"canadacentral"` |
| <a name="input_name"></a> [name](#input\_name) | REQUIRED:  This is name for your deployment | `string` | `"m-coleman"` |
| <a name="input_api_url"></a> [api\_url](#input\_api\_url) | REQUIRED:  This is your Volterra Namespace | `string` | `"https://f5-sa.console.ves.volterra.io/api"` |
| <a name="input_region"></a> [region](#input\_region) | Azure Region: US Gov Virginia, US Gov Arizona, etc | `string` | `"Canada Central"` |
| <a name="input_sshPublicKey"></a> [sshPublicKey](#input\_sshPublicKey) | OPTIONAL: ssh public key for instances | `string` | `""` |
| <a name="input_api_p12_file"></a> [api\_p12\_file](#input\_api\_p12\_file) | REQUIRED:  This is the path to the Volterra API Key.  See https://volterra.io/docs/how-to/user-mgmt/credentials | `string` | `"./creds/f5-sa.console.ves.volterra.io.api-creds.p12"` |
| <a name="input_sshPublicKeyPath"></a> [sshPublicKeyPath](#input\_sshPublicKeyPath) | OPTIONAL: ssh public key path for instances | `string` | `"./creds/id_rsa.pub"` |
| <a name="input_api_key"></a> [api\_key](#input\_api\_key) | REQUIRED:  This is the path to the Volterra API Key.  See https://volterra.io/docs/how-to/user-mgmt/credentials | `string` | `"./creds/api.key"` |
| <a name="input_volterra_tf_action"></a> [volterra\_tf\_action](#input\_volterra\_tf\_action) | n/a | `string` | `"apply"` |
| <a name="input_delegated_dns_domain"></a> [delegated\_dns\_domain](#input\_delegated\_dns\_domain) | n/a | `string` | `"ves.dimensionc-132.com"` |
| <a name="input_azure_client_id"></a> [azure\_client\_id](#input\_azure\_client\_id) | n/a | `string` | `""` |
| <a name="input_azure_client_secret"></a> [azure\_client\_secret](#input\_azure\_client\_secret) | n/a | `string` | `""` |
| <a name="input_azure_tenant_id"></a> [azure\_tenant\_id](#input\_azure\_tenant\_id) | n/a | `string` | `""` |
| <a name="input_azure_subscription_id"></a> [azure\_subscription\_id](#input\_azure\_subscription\_id) | n/a | `string` | `""` |
| <a name="input_gateway_type"></a> [gateway\_type](#input\_gateway\_type) | n/a | `string` | `"INGRESS_EGRESS_GATEWAY"` |
| <a name="input_fleet_label"></a> [fleet\_label](#input\_fleet\_label) | n/a | `string` | `"fleet_label"` |
| <a name="input_cidr"></a> [cidr](#input\_cidr) | REQUIRED: VNET Network CIDR | `string` | `"10.90.0.0/16"` |
| <a name="input_azure_subnets"></a> [azure\_subnets](#input\_azure\_subnets) | REQUIRED: Subnet CIDRs | `map(string)` | <pre>{<br>  "application": "10.90.10.0/24",<br>  "external": "10.90.1.0/24",<br>  "inspect_ext": "10.90.3.0/24",<br>  "inspect_int": "10.90.4.0/24",<br>  "internal": "10.90.2.0/24",<br>  "management": "10.90.0.0/24"<br>}</pre> |
| <a name="input_f5_mgmt"></a> [f5\_mgmt](#input\_f5\_mgmt) | F5 BIG-IP Management IPs.  These must be in the management subnet. | `map(string)` | <pre>{<br>  "f5vm01mgmt": "10.90.0.14",<br>  "f5vm02mgmt": "10.90.0.15"<br>}</pre> |
| <a name="input_f5_t1_ext"></a> [f5\_t1\_ext](#input\_f5\_t1\_ext) | Tier 1 BIG-IP External IPs.  These must be in the external subnet. | `map(string)` | <pre>{<br>  "f5vm01ext": "10.90.2.14",<br>  "f5vm01ext_fou": "10.90.2.13",<br>  "f5vm01ext_sec": "10.90.2.11",<br>  "f5vm01ext_thi": "10.90.2.12"<br>}</pre> |
| <a name="input_f5_t1_int"></a> [f5\_t1\_int](#input\_f5\_t1\_int) | Tier 1 BIG-IP Internal IPs.  These must be in the internal subnet. | `map(string)` | <pre>{<br>  "f5vm01int": "10.90.4.14",<br>  "f5vm01int_sec": "10.90.4.11"<br>}</pre> |
| <a name="input_app01ip"></a> [app01ip](#input\_app01ip) | OPTIONAL: Example Application used by all use-cases to demonstrate functionality of deploymeny, must reside in the application subnet. | `string` | `"10.90.10.101"` |
| <a name="input_instanceType"></a> [instanceType](#input\_instanceType) | BIGIP Instance Type, DS5\_v2 is a solid baseline for BEST | `string` | `"Standard_DS5_v2"` |
| <a name="input_jumpinstanceType"></a> [jumpinstanceType](#input\_jumpinstanceType) | Be careful which instance type selected, jump boxes currently use Premium\_LRS managed disks | `string` | `"Standard_B2s"` |
| <a name="input_appInstanceType"></a> [appInstanceType](#input\_appInstanceType) | Demo Application Instance Size | `string` | `"Standard_DS3_v2"` |
| <a name="input_image_name"></a> [image\_name](#input\_image\_name) | REQUIRED: BIG-IP Image Name.  'az vm image list --output table --publisher f5-networks --location [region] --offer f5-big-ip --all'  Default f5-bigip-virtual-edition-1g-best-hourly is PAYG Image.  For BYOL use f5-big-all-2slot-byol | `string` | `"f5-bigip-virtual-edition-1g-best-hourly"` |
| <a name="input_product"></a> [product](#input\_product) | REQUIRED: BYOL = f5-big-ip-byol, PAYG = f5-big-ip-best | `string` | `"f5-big-ip-best"` |
| <a name="input_bigip_version"></a> [bigip\_version](#input\_bigip\_version) | REQUIRED: BIG-IP Version.  Note: verify available versions before using as images can change. | `string` | `"latest"` |
| <a name="input_licenses"></a> [licenses](#input\_licenses) | BIGIP Setup Licenses are only needed when using BYOL images | `map(string)` | <pre>{<br>  "license1": "",<br>  "license2": "",<br>  "license3": "",<br>  "license4": ""<br>}</pre> |
| <a name="input_hosts"></a> [hosts](#input\_hosts) | n/a | `map(string)` | <pre>{<br>  "host1": "f5vm01",<br>  "host2": "f5vm02"<br>}</pre> |
| <a name="input_dns_server"></a> [dns\_server](#input\_dns\_server) | REQUIRED: Default is set to Azure DNS. | `string` | `"168.63.129.16"` |
| <a name="input_asm_policy"></a> [asm\_policy](#input\_asm\_policy) | REQUIRED: ASM Policy.  Examples:  https://github.com/f5devcentral/f5-asm-policy-templates.  Default: OWASP Ready Autotuning | `string` | `"https://raw.githubusercontent.com/f5devcentral/f5-asm-policy-templates/master/owasp_ready_template/owasp-auto-tune-v1.1.xml"` |
| <a name="input_ntp_server"></a> [ntp\_server](#input\_ntp\_server) | n/a | `string` | `"time.nist.gov"` |
| <a name="input_timezone"></a> [timezone](#input\_timezone) | n/a | `string` | `"UTC"` |
| <a name="input_onboard_log"></a> [onboard\_log](#input\_onboard\_log) | n/a | `string` | `"/var/log/startup-script.log"` |
| <a name="input_tags"></a> [tags](#input\_tags) | Environment tags for objects | `map(string)` | <pre>{<br>  "application": "f5app",<br>  "costcenter": "f5costcenter",<br>  "creator": "Terraform",<br>  "delete": "True",<br>  "environment": "azure",<br>  "group": "f5group",<br>  "owner": "f5owner",<br>  "purpose": "public"<br>}</pre> |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_auto_tag"></a> [auto\_tag](#output\_auto\_tag) | n/a |
| <a name="output_deployment_info"></a> [deployment\_info](#output\_deployment\_info) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Deployment

For deployment you can do the traditional terraform commands or use the provided scripts.

```bash
. ./prep.sh
terraform init
terraform plan
terraform apply
```

## Troubleshooting

AS, DO, and runtime-init are rendered under ./debug for review.  AS3 seems to occasionally fail on example partition, but is easily resolved with postman.  Working on resolution.

Currently getting 503 from Volterra, LTM shows now traffic reaching it, so probably a UDR issue.  Working on resultion.

## Support

For support, please open a GitHub issue.  Note, the code in this repository is community supported and is not supported by F5 Networks.  For a complete list of supported projects please reference [SUPPORT.md](SUPPORT.md).

## Community Code of Conduct

Please refer to the [F5 DevCentral Community Code of Conduct](code_of_conduct.md).

## License

[Apache License 2.0](LICENSE)

## Copyright

Copyright 2014-2020 F5 Networks Inc.

### F5 Networks Contributor License Agreement

Before you start contributing to any project sponsored by F5 Networks, Inc. (F5) on GitHub, you will need to sign a Contributor License Agreement (CLA).

If you are signing as an individual, we recommend that you talk to your employer (if applicable) before signing the CLA since some employment agreements may have restrictions on your contributions to other projects.
Otherwise by submitting a CLA you represent that you are legally entitled to grant the licenses recited therein.

If your employer has rights to intellectual property that you create, such as your contributions, you represent that you have received permission to make contributions on behalf of that employer, that your employer has waived such rights for your contributions, or that your employer has executed a separate CLA with F5.

If you are signing on behalf of a company, you represent that you are legally entitled to grant the license recited therein.
You represent further that each employee of the entity that submits contributions is authorized to submit such contributions on behalf of the entity pursuant to the CLA.
