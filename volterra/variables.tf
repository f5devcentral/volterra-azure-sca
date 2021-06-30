# Azure Environment
variable "projectPrefix" {}
variable "location" {}
variable "region" {}
variable "sshPublicKey" {}
variable "sshPublicKeyPath" {}
variable "existing_vnet" {}

variable "namespace" {
  default = "default"
}
// required variable
variable "api_p12_file" {}

// required variable
variable "name" {}

// required variable
variable "url" {}

// required variable
variable "azure_client_id" {}

// required variable
variable "azure_client_secret" {}

// required variable
variable "azure_tenant_id" {}

// required variable
variable "azure_subscription_id" {}

variable "resource_group_name" {}

variable "volterra_tf_action" {}

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
    "vdms"        = "10.90.3.0/24"
    "inspect_ext" = "10.90.4.0/24"
    "inspect_int" = "10.90.5.0/24"
    "waf_ext"     = "10.90.6.0/24"
    "waf_int"     = "10.90.7.0/24"
    "application" = "10.90.10.0/24"
  }
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
