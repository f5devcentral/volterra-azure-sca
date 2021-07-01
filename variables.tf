# Azure Environment
variable "projectPrefix" {
  type        = string
  description = "REQUIRED: Prefix to prepend to all objects created, minus Windows Jumpbox"
  default     = "bcbad9f1"
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
  default     = "canadacentral"
}
variable "region" {
  type        = string
  description = "Azure Region: US Gov Virginia, US Gov Arizona, etc"
  default     = "Canada Central"
}
variable "deploymentType" {
  type        = string
  description = "REQUIRED: This determines the type of deployment; one tier versus three tier: one_tier, three_tier"
  default     = "three_tier"
}
variable "sshPublicKey" {
  type        = string
  description = "OPTIONAL: ssh public key for instances"
  default     = ""
}
variable "sshPublicKeyPath" {
  type        = string
  description = "OPTIONAL: ssh public key path for instances"
  default     = "~/.ssh/id_rsa.pub"
}
variable "api_p12_file" {
  type        = string
  description = "REQUIRED:  This is the path to the Volterra API Key.  See https://volterra.io/docs/how-to/user-mgmt/credentials"
  default     = "./api-creds.p12"
}

variable "api_cert" {
  type        = string
  description = "REQUIRED:  This is the path to the Volterra API Key.  See https://volterra.io/docs/how-to/user-mgmt/credentials"
  default     = "./api2.cer"
}
variable "api_key" {
  type        = string
  description = "REQUIRED:  This is the path to the Volterra API Key.  See https://volterra.io/docs/how-to/user-mgmt/credentials"
  default     = "./api.key"
}

variable "tenant_name" {
  type        = string
  description = "REQUIRED:  This is your Volterra Tenant Name:  https://<tenant_name>.console.ves.volterra.io/api"
  default     = "mr-customer"
}

variable "namespace" {
  type        = string
  description = "REQUIRED:  This is your Volterra App Namespace"
  default     = "namespace"
}

variable "name" {
  type        = string
  description = "REQUIRED:  This is name for your deployment"
  default     = "nebula"
}
variable "volterra_tf_action" {
  default = "plan"
}

variable "api_url" {
  type        = string
  description = "REQUIRED:  This is your Volterra API url"
  default     = "https://playground.console.ves.volterra.io/api"
}

variable "azure_client_id" { default = "" }
variable "azure_client_secret" { default = "" }
variable "azure_tenant_id" { default = "" }
variable "azure_subscription_id" { default = "" }

variable "gateway_type" { default = "INGRESS_EGRESS_GATEWAY" }
variable "fleet_label" { default = "fleet_label" }

# NETWORK
variable "cidr" {
  description = "REQUIRED: VNET Network CIDR"
  default     = "10.90.0.0/16"
}

variable "azure_subnets" {
  type        = map(string)
  description = "REQUIRED: Subnet CIDRs"
  default = {
    "management"  = "10.90.0.0/24"
    "external"    = "10.90.1.0/24"
    "internal"    = "10.90.2.0/24"
    "inspect_ext" = "10.90.4.0/24"
    "inspect_int" = "10.90.5.0/24"
    "application" = "10.90.10.0/24"
  }
}

variable "f5_mgmt" {
  description = "F5 BIG-IP Management IPs.  These must be in the management subnet."
  type        = map(string)
  default = {
    f5vm01mgmt = "10.90.0.14"
    f5vm02mgmt = "10.90.0.15"
  }
}

# bigip external private ips, these must be in external subnet
variable "f5_t1_ext" {
  description = "Tier 1 BIG-IP External IPs.  These must be in the external subnet."
  type        = map(string)
  default = {
    f5vm01ext     = "10.90.4.14"
    f5vm01ext_sec = "10.90.4.11"
    f5vm02ext     = "10.90.4.15"
    f5vm02ext_sec = "10.90.4.12"
  }
}

variable "f5_t1_int" {
  description = "Tier 1 BIG-IP Internal IPs.  These must be in the internal subnet."
  type        = map(string)
  default = {
    f5vm01int     = "10.90.5.14"
    f5vm01int_sec = "10.90.5.11"
    f5vm02int     = "10.90.5.15"
    f5vm02int_sec = "10.90.5.12"
  }
}


variable "app01ip" {
  type        = string
  description = "OPTIONAL: Example Application used by all use-cases to demonstrate functionality of deploymeny, must reside in the application subnet."
  default     = "10.90.10.101"
}

# Example IPS private ips
variable "ips01ext" { default = "10.90.4.4" }
variable "ips01int" { default = "10.90.5.4" }
variable "ips01mgmt" { default = "10.90.0.8" }

variable "winjumpip" {
  type        = string
  description = "REQUIRED: Used by all use-cases for RDP/Windows Jumpbox, must reside in VDMS subnet."
  default     = "10.90.3.98"
}

variable "linuxjumpip" {
  type        = string
  description = "REQUIRED: Used by all use-cases for SSH/Linux Jumpbox, must reside in VDMS subnet."
  default     = "10.90.3.99"
}

# BIGIP Instance Type, DS5_v2 is a solid baseline for BEST
variable "instanceType" { default = "Standard_DS5_v2" }

# Be careful which instance type selected, jump boxes currently use Premium_LRS managed disks
variable "jumpinstanceType" { default = "Standard_B2s" }

# Demo Application Instance Size
variable "appInstanceType" { default = "Standard_DS3_v2" }

# BIGIP Image
variable "image_name" {
  type        = string
  description = "REQUIRED: BIG-IP Image Name.  'az vm image list --output table --publisher f5-networks --location [region] --offer f5-big-ip --all'  Default f5-bigip-virtual-edition-1g-best-hourly is PAYG Image.  For BYOL use f5-big-all-2slot-byol"
  default     = "f5-bigip-virtual-edition-1g-best-hourly"
}
variable "product" {
  type        = string
  description = "REQUIRED: BYOL = f5-big-ip-byol, PAYG = f5-big-ip-best"
  default     = "f5-big-ip-best"
}
variable "bigip_version" {
  type        = string
  description = "REQUIRED: BIG-IP Version.  Note: verify available versions before using as images can change."
  default     = "latest"
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
  }
}

variable "dns_server" {
  type        = string
  description = "REQUIRED: Default is set to Azure DNS."
  default     = "168.63.129.16"
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
  description = "Environment tags for objects"
  type        = map(string)
  default = {
    "purpose"     = "public"
    "environment" = "f5env"
    "owner"       = "f5owner"
    "group"       = "f5group"
    "costcenter"  = "f5costcenter"
    "application" = "f5app"
  }
}
