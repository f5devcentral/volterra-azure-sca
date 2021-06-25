module azure {
  source        = "./azure"
  location      = var.location
  projectPrefix = var.projectPrefix
}

module volterra {
  source = "./volterra"

  tenant_name      = var.tenant_name
  namespace        = var.namespace
  url              = "https://${var.tenant_name}.console.ves.volterra.io/api"
  api_p12_file     = var.api_p12_file
  api_cert         = var.api_p12_file != "" ? "" : var.api_cert
  api_key          = var.api_p12_file != "" ? "" : var.api_key
  region           = var.region
  location         = var.location
  projectPrefix    = var.projectPrefix
  sshPublicKeyPath = var.sshPublicKeyPath
}

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
