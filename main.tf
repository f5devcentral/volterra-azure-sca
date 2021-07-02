# main.tf

# Util Module
# - Random Prefix Generation
# - Random Password Generation
module "util" {
  source = "./util"
}

# Azure Module
# Create all Azure Dependencies
module "azure" {
  source        = "./azure"
  location      = var.location
  namespace     = var.namespace
  projectPrefix = module.util.env_prefix
  cidr          = var.cidr
  subnets       = var.azure_subnets
  tags          = var.tags
}

# Volterra Module
# Build Site Token and Cloud Credential
# Build out Azure Site
# Build out Origin Pool & LB
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
  projectPrefix         = module.util.env_prefix
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
  subnet_internal       = module.azure.azure_subnet_internal
  subnet_external       = module.azure.azure_subnet_external
  bigip_external        = var.f5_t1_ext["f5vm01ext"]
  delegated_domain      = var.delegated_dns_domain
  tags                  = var.tags
}

module "firewall" {
  source = "./firewall"
  depends_on = [
    module.azure.azure_resource_group_main, module.azure.azure_key_vault_secret, module.azure.azure_virtual_network_main, module.azure.azure_subnet_internal, module.azure.azure_subnet_external, module.azure.azure_key_vault_uri, module.azure.azure_key_vault_secret
  ]
  sshPublicKey           = var.sshPublicKeyPath
  location               = var.location
  region                 = var.region
  resource_group         = module.azure.azure_resource_group_main
  azure_key_vault_uri    = module.azure.azure_key_vault_uri
  azure_key_vault_secret = module.azure.azure_key_vault_secret
  security_group         = module.azure.azurerm_network_security_group_main
  namespace              = var.namespace
  subnetMgmt             = module.azure.azure_subnet_mgmt
  subnetExternal         = module.azure.azure_subnet_inspec_ext
  subnetInternal         = module.azure.azure_subnet_inspec_int
  availability_set       = module.azure.azure_availability_set_avset
  image_name             = var.image_name
  product                = var.product
  bigip_version          = var.bigip_version
  adminUserName          = var.adminUserName
  adminPassword          = module.util.admin_password
  projectPrefix          = module.util.env_prefix
  instanceType           = var.instanceType
  subnets                = var.azure_subnets
  cidr                   = var.cidr
  app01ip                = var.app01ip
  hosts                  = var.hosts
  f5_mgmt                = var.f5_mgmt
  f5_t1_ext              = var.f5_t1_ext
  f5_t1_int              = var.f5_t1_int
  winjumpip              = var.winjumpip
  linuxjumpip            = var.linuxjumpip
  licenses               = var.licenses
  asm_policy             = var.asm_policy
  tags                   = var.tags
  timezone               = var.timezone
  ntp_server             = var.ntp_server
  dns_server             = var.dns_server
}

module "applications" {
  source         = "./applications"
  location       = var.location
  region         = var.region
  resource_group = module.azure.azure_resource_group_main
  projectPrefix  = module.util.env_prefix
  security_group = module.azure.azurerm_network_security_group_main
  appSubnet      = module.azure.azurerm_subnet_application
  adminUserName  = var.adminUserName
  adminPassword  = module.util.admin_password
  app01ip        = var.app01ip
  tags           = var.tags
  timezone       = var.timezone
  instanceType   = var.appInstanceType
}
