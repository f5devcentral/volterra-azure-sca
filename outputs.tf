## OUTPUTS ###

output "volterra_site_token" {
  value = "Token: ${module.volterra.token}"
}
output "volterra_cloud_credential" {
  value = "Credential: ${module.volterra.credentials}"
}
output "big_ip_management" {
  value = "https://${module.firewall.azurerm_public_ip_pip}"
}
output "azure_key_vault_uri" {
  value = module.azure.azure_key_vault_uri
}
