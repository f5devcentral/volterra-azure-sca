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

resource volterra_token terraform_token {
  name        = "token-${var.namespace}-${var.tenant_name}"
  namespace   = "system"
  description = "Coleman Terraform Created Token"
}

output token {
  value = volterra_token.terraform_token.id
}

resource volterra_azure_vnet_site azure_site {
  name         = "${var.namespace}-${var.tenant_name}-vnet-site"
  namespace    = "system"
  azure_region = var.location

  #ssh_key = var.ssh_key

  // One of the arguments from this list "azure_cred assisted" must be set
  assisted = true

  // One of the arguments from this list "logs_streaming_disabled log_receiver" must be set
  logs_streaming_disabled = true
  resource_group          = "resource_group"

  // One of the arguments from this list "ingress_egress_gw voltstack_cluster ingress_gw" must be set

  ingress_egress_gw {
    no_forward_proxy         = true
    no_global_network        = true
    no_inside_static_routes  = true
    no_network_policy        = true
    no_outside_static_routes = true

    az_nodes {
      azure_az  = "1"
      disk_size = "0"

      inside_subnet {
        // One of the arguments from this list "subnet_param subnet" must be set

        subnet_param {
          ipv4 = "10.1.1.0/24"
          ipv6 = ""
        }
      }
      outside_subnet {
        subnet_param {
          ipv4 = "10.1.0.0/24"
          ipv6 = ""
        }
      }
    }

    azure_certified_hw = "azure-byol-multi-nic-voltmesh"
  }
  vnet {
    // One of the arguments from this list "new_vnet existing_vnet" must be set

    new_vnet {
      #resource_group = "${var.namespace}-${projectPrefix}"
      #vnet_name      = "${var.namespace}-${projectPrefix}-vnet"
      autogenerate = true
      primary_ipv4 = "10.1.0.0/16"
    }
  }
}
