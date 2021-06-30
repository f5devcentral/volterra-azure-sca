# azure.tf

# Create a Resource Group for the new Virtual Machines
resource "azurerm_resource_group" "main" {
  name     = "${var.projectPrefix}_rg"
  location = var.location
}

# Create Availability Set
resource "azurerm_availability_set" "avset" {
  name                         = "${var.projectPrefix}-avset"
  location                     = azurerm_resource_group.main.location
  resource_group_name          = azurerm_resource_group.main.name
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true
}

# Create a Virtual Network within the Resource Group
resource "azurerm_virtual_network" "main" {
  name                = "${var.projectPrefix}-network"
  address_space       = [var.cidr]
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
}

# Create the Management Subnet within the Virtual Network
resource "azurerm_subnet" "mgmt" {
  name                 = "mgmt"
  virtual_network_name = azurerm_virtual_network.main.name
  resource_group_name  = azurerm_resource_group.main.name
  address_prefixes     = [var.subnets["management"]]
}

# Create the external Subnet within the Virtual Network
resource "azurerm_subnet" "external" {
  name                 = "external"
  virtual_network_name = azurerm_virtual_network.main.name
  resource_group_name  = azurerm_resource_group.main.name
  address_prefixes     = [var.subnets["external"]]
}

# Create the internal Subnet within the Virtual Network
resource "azurerm_subnet" "internal" {
  name                 = "internal"
  virtual_network_name = azurerm_virtual_network.main.name
  resource_group_name  = azurerm_resource_group.main.name
  address_prefixes     = [var.subnets["internal"]]
}

# Obtain Gateway IP for each Subnet
locals {
  depends_on = [azurerm_subnet.mgmt, azurerm_subnet.external]
  mgmt_gw    = cidrhost(azurerm_subnet.mgmt.address_prefix, 1)
  ext_gw     = cidrhost(azurerm_subnet.external.address_prefix, 1)
  int_gw     = cidrhost(azurerm_subnet.internal.address_prefix, 1)
}

# outputs
output "azure_resource_group_main" { value = azurerm_resource_group.main }
output "azure_availability_set_avset" { value = azurerm_availability_set.avset }
output "azure_virtual_network_main" { value = azurerm_virtual_network.main }
output "azure_subnet_mgmt" { value = azurerm_subnet.mgmt }
output "azure_subnet_external" { value = azurerm_subnet.external }
output "azure_subnet_internal" { value = azurerm_subnet.internal }
