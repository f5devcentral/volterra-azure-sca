terraform {
  required_version = ">= 0.13"
  required_providers {
    volterra = {
      source  = "volterraedge/volterra"
      version = "0.7.0"
    }
  }
}

provider volterra {
  api_p12_file = var.api_p12_file
  api_cert     = var.api_p12_file != "" ? "" : var.api_cert
  api_key      = var.api_p12_file != "" ? "" : var.api_key
  #api_ca_cert  = var.api_ca_cert
  url = var.url
}

resource volterra_token new_site {
  name        = "${var.namespace}-${var.tenant_name}-sca-token"
  #name      = "m-coleman-tf-sca-token"
  namespace = "system"
}

output token {
  value = volterra_token.new_site.id
}

resource volterra_cloud_credentials azure_site {
  name      = "${var.namespace}-${var.tenant_name}-azure-credentials"
  namespace = "system"

  azure_client_secret {
    client_id       = var.azure_client_id
    subscription_id = var.azure_subscription_id
    tenant_id       = var.azure_tenant_id

    client_secret {
      # blindfold_secret_info_internal {
      #   location = "string:///${var.azure_client_secret}"
      # }
      clear_secret_info {
        url = "string:///${var.azure_client_secret}"
      }
    }

  }
}

resource volterra_azure_vnet_site azure_site {
  name         = "${var.tenant_name}-${var.namespace}-vnet-site"
  namespace    = "system"
  azure_region = var.location
  ssh_key      = file(var.sshPublicKeyPath)

  machine_type = "Standard_D3_v2"

  coordinates {
    latitude  = "43.653"
    longitude = "-79.383"
  }
  #assisted = true
  azure_cred {
    name      = volterra_cloud_credentials.azure_site.name
    namespace = "system"
  }

  // One of the arguments from this list "logs_streaming_disabled log_receiver" must be set
  logs_streaming_disabled = true
  resource_group          = "resource_group"

  // One of the arguments from this list "ingress_egress_gw voltstack_cluster ingress_gw" must be set

  ingress_egress_gw {
    azure_certified_hw = "azure-byol-multi-nic-voltmesh"

    no_forward_proxy         = true
    no_global_network        = true
    no_inside_static_routes  = true
    no_network_policy        = true
    no_outside_static_routes = true

    az_nodes {
      azure_az  = "1"
      disk_size = "80"

      inside_subnet {
        subnet_param {
          ipv4 = "10.1.1.0/24"
        }
      }
      outside_subnet {
        subnet_param {
          ipv4 = "10.1.0.0/24"
        }
      }
    }

  }
  vnet {
    new_vnet {
      autogenerate = true
      primary_ipv4 = "10.1.0.0/16"
    }
  }
}

resource volterra_tf_params_action action_test {
  site_name       = volterra_azure_vnet_site.azure_site.name
  site_kind       = "azure_vnet_site"
  action          = "plan"
  wait_for_action = false
}
