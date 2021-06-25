# Create a Resource Group for the new Virtual Machines
resource azurerm_resource_group main {
  name     = "${var.projectPrefix}_rg"
  location = var.location
}


# Create Availability Set
resource azurerm_availability_set avset {
  name                         = "${var.projectPrefix}-avset"
  location                     = azurerm_resource_group.main.location
  resource_group_name          = azurerm_resource_group.main.name
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true
}
