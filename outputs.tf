## OUTPUTS ###

# output sg_id {
#   value       = azurerm_network_security_group.main.id
#   description = "Network Security Group ID"
# }
# output sg_name {
#   value       = azurerm_network_security_group.main.name
#   description = "Network Security Group Name"
# }

output volterra {
  value = "Token: ${module.volterra.token}"
}
