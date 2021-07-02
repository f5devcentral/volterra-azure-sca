## OUTPUTS ###

# output "volterra_site_token" {
#   value = "Token: ${module.volterra.token}"
# }
# output "volterra_cloud_credential" {
#   value = "Credential: ${module.volterra.credentials}"
# }
# output "big_ip_management" {
#   value = "https://${module.firewall.azurerm_public_ip_pip}"
# }
# output "azure_key_vault_uri" {
#   value = module.azure.azure_key_vault_uri
# }

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
      }
    ]
    deploymentId = module.util.env_prefix
  }
}
