# Azure Environment
variable "projectPrefix" {
  type        = string
  description = "REQUIRED: Prefix to prepend to all objects created, minus Windows Jumpbox"
  default     = "ccbad9f1"
}
variable "adminUserName" {
  type        = string
  description = "REQUIRED: Admin Username for All systems"
  default     = "xadmin"
}
variable "adminPassword" {
  type        = string
  description = "REQUIRED: Admin Password for all systems"
  default     = "pleaseUseVault123!!"
}
variable "location" {
  type        = string
  description = "REQUIRED: Azure Region: usgovvirginia, usgovarizona, etc. For a list of available locations for your subscription use `az account list-locations -o table`"
  default     = "usgovvirginia"
}
variable "region" {
  type        = string
  description = "Azure Region: US Gov Virginia, US Gov Arizona, etc"
  default     = "US Gov Virginia"
}
variable "deploymentType" {
  type        = string
  description = "REQUIRED: This determines the type of deployment; one tier versus three tier: one_tier, three_tier"
  default     = "three_tier"
}
variable "deployDemoApp" {
  type        = string
  description = "OPTIONAL: Deploy Demo Application with Stack. Recommended to show functionality.  Options: deploy, anything else."
  default     = "deploy"
}
variable "sshPublicKey" {
  type        = string
  description = "OPTIONAL: ssh public key for instances"
  default     = ""
}
variable "sshPublicKeyPath" {
  type        = string
  description = "OPTIONAL: ssh public key path for instances"
  default     = "/mykey.pub"
}
variable "api_p12_file" {
  type        = string
  description = "REQUIRED:  This is the path to the Volterra API Key.  See https://volterra.io/docs/how-to/user-mgmt/credentials"
  default     = "./creds/api-creds.p12"
}

variable "api_cert" {
  type        = string
  description = "REQUIRED:  This is the path to the Volterra API Key.  See https://volterra.io/docs/how-to/user-mgmt/credentials"
  default     = "./creds/api-creds.p12"
}
variable "api_key" {
  type        = string
  description = "REQUIRED:  This is the path to the Volterra API Key.  See https://volterra.io/docs/how-to/user-mgmt/credentials"
  default     = "./creds/api-creds.p12"
}

variable "tenant_name" {
  type        = string
  description = "REQUIRED:  This is your Volterra Tenant Name:  https://<tenant_name>.console.ves.volterra.io/api"
  default     = "mr-customer"
}

variable "subnetMgmt" {}
variable "subnetExternal" {}
variable "subnetInternal" {}
variable "availability_set" {}
variable "security_group" {}
variable "app_security_group" {}

variable "namespace" {}

variable "resource_group" {}

variable "azure_key_vault_uri" {}
variable "azure_key_vault_secret" {}

# NETWORK
variable "cidr" {
  description = "REQUIRED: VNET Network CIDR"
  default     = "10.90.0.0/16"
}

variable "subnets" {}

variable "f5_mgmt" {}

# bigip external private ips, these must be in external subnet
variable "f5_t1_ext" {
}

variable "f5_t1_int" {
}

variable "internalILBIPs" {
  description = "REQUIRED: Used by One and Three Tier.  Azure internal load balancer ips, these are used for ingress and egress."
  type        = map(string)
  default     = {}
}


variable "app01ip" {
}

# BIGIP Instance Type, DS5_v2 is a solid baseline for BEST
variable "instanceType" { default = "Standard_DS5_v2" }

# Be careful which instance type selected, jump boxes currently use Premium_LRS managed disks
variable "jumpinstanceType" { default = "Standard_B2s" }

# Demo Application Instance Size
variable "appInstanceType" { default = "Standard_DS3_v2" }

# BIGIP Image
variable "image_name" {

}
variable "product" {

}
variable "bigip_version" {

}

# BIGIP Setup
# Licenses are only needed when using BYOL images
variable "licenses" {
  type = map(string)
  default = {
    "license1" = ""
    "license2" = ""
    "license3" = ""
    "license4" = ""
  }
}

variable "hosts" {
  type = map(string)
  default = {
    "host1" = "f5vm01"
    "host2" = "f5vm02"
    "host3" = "f5vm03"
    "host4" = "f5vm04"
  }
}

variable "dns_server" {

}

## ASM Policy
variable "asm_policy" {
  type        = string
  description = "REQUIRED: ASM Policy.  Examples:  https://github.com/f5devcentral/f5-asm-policy-templates.  Default: OWASP Ready Autotuning"
  default     = "https://raw.githubusercontent.com/f5devcentral/f5-asm-policy-templates/master/owasp_ready_template/owasp-auto-tune-v1.1.xml"
}

variable "ntp_server" { default = "time.nist.gov" }
variable "timezone" { default = "UTC" }
variable "onboard_log" { default = "/var/log/startup-script.log" }

# TAGS
variable "tags" {

}
