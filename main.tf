# main.tf

module "azure" {
  source        = "./azure"
  location      = var.location
  projectPrefix = var.projectPrefix
  cidr          = var.cidr
  subnets       = var.azure_subnets
}

module "volterra" {
  source = "./volterra"

  depends_on = [
    module.azure.azure_resource_group_main, module.azure.azure_virtual_network_main, module.azure.azure_subnet_internal, module.azure.azure_subnet_external
  ]
  name      = var.name
  namespace = var.namespace
  #resource_group_name   = "${var.projectPrefix}_rg"
  resource_group_name   = module.azure.azure_resource_group_main.name
  fleet_label           = var.fleet_label
  url                   = var.api_url
  api_p12_file          = var.api_p12_file
  region                = var.region
  location              = var.location
  projectPrefix         = var.projectPrefix
  sshPublicKeyPath      = var.sshPublicKeyPath
  sshPublicKey          = var.sshPublicKey
  azure_client_id       = var.azure_client_id
  azure_client_secret   = var.azure_client_secret
  azure_tenant_id       = var.azure_tenant_id
  azure_subscription_id = var.azure_subscription_id
  gateway_type          = var.gateway_type
  volterra_tf_action    = var.volterra_tf_action
  existing_vnet         = module.azure.azure_virtual_network_main
  cidr                  = var.cidr
  azure_subnets         = var.azure_subnets
}

# module "firewall" {
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
#   subnets       = var.azure_subnets
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
