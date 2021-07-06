## OUTPUTS ###

output "auto_tag" {
  value = {
    #primary_sub    = module.azure.azure_subscription_primary.id
    resource_group = module.azure.azure_resource_group_main.name
    volt_group     = module.volterra.volterra_resource_group.name
    tags           = module.volterra.volterra_resource_group_tags
  }
}

output "deployment_info" {
  value = {
    instances = [
      {
        admin_username            = var.adminUserName
        admin_password            = module.util.admin_password
        mgmt_address              = "https://${module.firewall.azurerm_public_ip_pip}"
        azure_key_vault_uri       = module.azure.azure_key_vault_uri
        volterra_cloud_credential = module.volterra.credentials
        volterra_site_token       = module.volterra.token
        azure_resource_group      = module.azure.azure_resource_group_main.name
      }
    ]
    deploymentId = module.util.env_prefix
  }
}
