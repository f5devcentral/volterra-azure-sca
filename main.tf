module "volterra" {
  source = "./volterra"

  tenant_name           = var.tenant_name
  namespace             = var.namespace
  fleet_label           = var.fleet_label
  url                   = var.api_url
  api_p12_file          = var.api_p12_file
  api_cert              = var.api_p12_file != "" ? "" : var.api_cert
  api_key               = var.api_p12_file != "" ? "" : var.api_key
  region                = var.region
  location              = var.location
  projectPrefix         = var.projectPrefix
  sshPublicKeyPath      = var.sshPublicKeyPath
  azure_client_id       = var.azure_client_id
  azure_client_secret   = var.azure_client_secret
  azure_tenant_id       = var.azure_tenant_id
  azure_subscription_id = var.azure_subscription_id
  gateway_type          = var.gateway_type
}

# module azure {
#   source        = "./azure"
#   location      = var.location
#   projectPrefix = var.projectPrefix
# }

# module firewall {
#   source        = "./firewall"
#   sshPublicKey  = var.sshPublicKeyPath
#   location      = var.location
#   region        = var.region
#   image_name    = var.image_name
#   product       = var.product
#   bigip_version = var.bigip_version
#   adminUserName = var.adminUserName
#   adminPassword = var.adminPassword
#   projectPrefix = var.projectPrefix
#   instanceType  = var.instanceType
#   subnets       = var.subnets
#   cidr          = var.cidr
#   app01ip       = var.app01ip
#   hosts         = var.hosts
#   f5_mgmt       = var.f5_mgmt
#   f5_t1_ext     = var.f5_t1_ext
#   f5_t1_int     = var.f5_t1_int
#   winjumpip     = var.winjumpip
#   linuxjumpip   = var.linuxjumpip
#   licenses      = var.licenses
#   ilb01ip       = var.ilb01ip
#   asm_policy    = var.asm_policy
#   tags          = var.tags
#   timezone      = var.timezone
#   ntp_server    = var.ntp_server
#   dns_server    = var.dns_server
# }
