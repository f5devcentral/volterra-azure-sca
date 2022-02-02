# # Create UDRS

resource "azurerm_route_table" "inspect_external" {
  name                          = "${var.projectPrefix}_external_rt"
  resource_group_name           = var.azure_resource_group_name
  location                      = var.location
  disable_bgp_route_propagation = false
}

resource "azurerm_route" "ext_within_vnet" {
  name                = "within-vnet"
  resource_group_name = var.azure_resource_group_name

  route_table_name = azurerm_route_table.inspect_external.name
  address_prefix   = var.cidr
  next_hop_type    = "VirtualAppliance"

  next_hop_in_ip_address = data.azurerm_network_interface.sli.private_ip_address
}

resource "azurerm_route" "ext_within_subnet" {
  name                = "within-subnet"
  resource_group_name = var.azure_resource_group_name

  route_table_name = azurerm_route_table.inspect_external.name
  address_prefix   = var.azure_subnets["inspect_ext"]
  next_hop_type    = "VnetLocal"
}

resource "azurerm_route" "ext_default" {
  name                = "default-nva"
  resource_group_name = var.azure_resource_group_name

  route_table_name = azurerm_route_table.inspect_external.name
  address_prefix   = "0.0.0.0/0"
  next_hop_type    = "VnetLocal"
}

resource "azurerm_subnet_route_table_association" "inspect_ext_associate" {
  subnet_id      = var.subnet_inspec_ext.id
  route_table_id = azurerm_route_table.inspect_external.id
}
