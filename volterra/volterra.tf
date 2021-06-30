terraform {
  required_version = ">= 0.12"
  required_providers {
    volterra = {
      source  = "volterraedge/volterra"
      version = "0.7.0"
    }
  }
}

# provider "volterra" {
#   api_p12_file = var.api_p12_file
#   url          = var.url
# }

resource "volterra_token" "new_site" {
  name      = format("%s-sca-token", var.name)
  namespace = "system"
}

output "token" {
  value = volterra_token.new_site.id
}

resource "volterra_cloud_credentials" "azure_site" {
  name      = format("%s-azure-credentials", var.name)
  namespace = "system"
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
  name         = format("%s-vnet-site", var.name)
  namespace    = "system"
  azure_region = var.location
  #resource_group = var.resource_group_name
  resource_group = "${var.projectPrefix}_volt_rg"
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

  // One of the arguments from this list "logs_streaming_disabled log_receiver" must be set
  logs_streaming_disabled = true

  ingress_egress_gw {
    azure_certified_hw = "azure-byol-multi-nic-voltmesh"

    no_forward_proxy         = true
    no_global_network        = true
    no_inside_static_routes  = true
    no_network_policy        = true
    no_outside_static_routes = true

    az_nodes {
      azure_az = "1"

      inside_subnet {
        subnet {
          subnet_resource_grp = var.resource_group_name
          vnet_resource_group = true
          subnet_name         = "internal"
        }
        # subnet_param {
        #   #ipv4 = "10.1.1.0/24"
        #   ipv4 = var.azure_subnets["internal"]
        # }
      }
      outside_subnet {
        subnet {
          subnet_resource_grp = var.resource_group_name
          vnet_resource_group = true
          subnet_name         = "external"
        }
        # subnet_param {
        #   #ipv4 = "10.1.0.0/24"
        #   ipv4 = var.azure_subnets["external"]
        # }
      }
    }

  }
  vnet {
    # new_vnet {
    #   autogenerate = true
    #   #primary_ipv4 = "10.1.0.0/16"
    #   primary_ipv4 = var.cidr
    # }
    existing_vnet {
      resource_group = var.resource_group_name
      vnet_name      = var.existing_vnet.name
    }
  }
}

resource "volterra_tf_params_action" "action_test" {
  site_name       = volterra_azure_vnet_site.azure_site.name
  site_kind       = "azure_vnet_site"
  action          = var.volterra_tf_action
  wait_for_action = false
}