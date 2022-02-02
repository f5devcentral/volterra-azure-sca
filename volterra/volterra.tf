terraform {
  required_version = ">= 0.12"
  required_providers {
    volterra = {
      source  = "volterraedge/volterra"
      version = "0.11.3"
    }
  }
}

resource "volterra_token" "new_site" {
  name      = format("%s-sca-token", var.name)
  namespace = "system"

  labels = var.tags
}

output "token" {
  value = volterra_token.new_site.id
}

resource "volterra_cloud_credentials" "azure_site" {
  name      = format("%s-azure-credentials", var.name)
  namespace = "system"
  labels    = var.tags
  azure_client_secret {
    client_id       = var.azure_client_id
    subscription_id = var.azure_subscription_id
    tenant_id       = var.azure_tenant_id
    client_secret {
      clear_secret_info {
        url = "string:///${base64encode(var.azure_client_secret)}"
      }
    }

  }
}

output "credentials" {
  value = volterra_cloud_credentials.azure_site.name
}



resource "volterra_azure_vnet_site" "azure_site" {
  name      = format("%s-vnet-site", var.name)
  namespace = "system"
  labels    = var.tags

  depends_on = [
    var.subnet_internal, var.subnet_external
  ]

  azure_region = var.location
  #resource_group = var.resource_group_name
  resource_group = var.resource_group_name
  ssh_key        = file(var.sshPublicKeyPath)

  machine_type = "Standard_D3_v2"

  # commenting out the co-ordinates because of below issue
  # https://github.com/volterraedge/terraform-provider-volterra/issues/61
  #coordinates {
  #  latitude  = "43.653"
  #  longitude = "-79.383"
  #}

  #assisted = true
  azure_cred {
    name      = volterra_cloud_credentials.azure_site.name
    namespace = "system"
  }

  # new error when no worker nodes?
  # nodes_per_az = 1
  no_worker_nodes = true
  # worker_nodes = 0

  // One of the arguments from this list "logs_streaming_disabled log_receiver" must be set
  logs_streaming_disabled = true

  vnet {

    existing_vnet {
      resource_group = var.azure_resource_group_name
      vnet_name      = var.existing_vnet.name
    }

  }

  ingress_egress_gw {
    azure_certified_hw = "azure-byol-multi-nic-voltmesh"
    // azure-byol-multi-nic-voltmesh

    no_forward_proxy  = true
    no_global_network = true
    #no_inside_static_routes  = true
    no_network_policy        = true
    no_outside_static_routes = true

    inside_static_routes {
      static_route_list {
        custom_static_route {
          attrs = [
            "ROUTE_ATTR_INSTALL_HOST",
            "ROUTE_ATTR_INSTALL_FORWARDING"
          ]
          subnets {
            ipv4 {
              prefix = "10.90.0.0"
              plen   = 16
            }
          }
          nexthop {
            type = "NEXT_HOP_USE_CONFIGURED"
            nexthop_address {
              ipv4 {
                addr = "10.90.2.1"
              }
            }
            interface {
              namespace = "system"
              name      = "ves-io-azure-vnet-site-${format("%s-vnet-site", var.name)}-inside"
            }
          }
        }
        custom_static_route {
          attrs = [
            "ROUTE_ATTR_INSTALL_HOST",
            "ROUTE_ATTR_INSTALL_FORWARDING"
          ]
          subnets {
            ipv4 {
              prefix = "0.0.0.0"
              plen   = 0
            }
          }
          nexthop {
            type = "NEXT_HOP_NETWORK_INTERFACE"
            nexthop_address {
              ipv4 {
                addr = ""
              }
            }
            interface {
              namespace = "system"
              name      = "ves-io-azure-vnet-site-${format("%s-vnet-site", var.name)}-inside"
            }
          }
        }
      }
    }

    az_nodes {
      azure_az = "1"

      outside_subnet {
        subnet {
          subnet_resource_grp = var.azure_resource_group_name
          vnet_resource_group = true
          subnet_name         = "external"
        }
      }

      inside_subnet {
        subnet {
          subnet_resource_grp = var.azure_resource_group_name
          vnet_resource_group = true
          subnet_name         = "internal"
        }
      }

    }

  }

}

resource "volterra_tf_params_action" "action_test" {
  site_name       = volterra_azure_vnet_site.azure_site.name
  site_kind       = "azure_vnet_site"
  action          = var.volterra_tf_action
  wait_for_action = true
}

data "azurerm_resources" "volterra_resource_group" {
  depends_on = [
    volterra_tf_params_action.action_test
  ]
  name = var.resource_group_name
}

data "azurerm_network_interface" "sli" {
  depends_on = [
    volterra_tf_params_action.action_test
  ]
  name                = "master-0-sli"
  resource_group_name = var.resource_group_name
}

output "azure_network_interface_sli_ip" {
  value = data.azurerm_network_interface.sli.private_ip_address
}

# Create RT-0
resource "azurerm_route_table" "route_table" {
  depends_on = [
    volterra_tf_params_action.action_test
  ]
  name                          = "rt-0"
  resource_group_name           = var.resource_group_name
  location                      = var.location
  disable_bgp_route_propagation = false
}

resource "azurerm_route" "default" {
  depends_on = [
    volterra_tf_params_action.action_test
  ]
  name                = "default-route"
  resource_group_name = var.resource_group_name

  route_table_name       = azurerm_route_table.route_table.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = data.azurerm_network_interface.sli.private_ip_address
}

resource "azurerm_subnet_route_table_association" "associate" {
  depends_on = [
    volterra_tf_params_action.action_test
  ]
  subnet_id      = var.subnet_internal.id
  route_table_id = azurerm_route_table.route_table.id
}

data "azurerm_network_security_group" "security_group" {
  depends_on = [
    volterra_tf_params_action.action_test
  ]
  name                = "security-group"
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet_network_security_group_association" "external_association" {
  depends_on = [
    volterra_tf_params_action.action_test
  ]
  subnet_id                 = var.subnet_external.id
  network_security_group_id = data.azurerm_network_security_group.security_group.id
}

resource "azurerm_subnet_network_security_group_association" "internal_association" {
  depends_on = [
    volterra_tf_params_action.action_test
  ]
  subnet_id                 = var.subnet_internal.id
  network_security_group_id = data.azurerm_network_security_group.security_group.id
}

output "volterra_resource_group" {
  value = data.azurerm_resources.volterra_resource_group
}

output "volterra_resource_group_tags" {
  value = merge(var.tags, { vesio_site_name = "${volterra_azure_vnet_site.azure_site.name}" })
}
