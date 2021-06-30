## OUTPUTS ###

output "volterra_site_token" {
  value = "Token: ${module.volterra.token}"
}
output "volterra_cloud_credential" {
  value = "Credential: ${module.volterra.credentials}"
}
