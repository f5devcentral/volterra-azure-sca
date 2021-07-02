terraform {
  required_version = ">= 0.12"
  required_providers {
    volterra = {
      source  = "volterraedge/volterra"
      version = "0.7.0"
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
      }
      outside_subnet {
        subnet {
          subnet_resource_grp = var.resource_group_name
          vnet_resource_group = true
          subnet_name         = "external"
        }
      }
    }

  }
  vnet {

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
  wait_for_action = true
}

resource "volterra_origin_pool" "kibana" {
  name      = format("%s-kibana-pool", var.name)
  namespace = var.namespace
  labels    = var.tags

  depends_on = [
    volterra_tf_params_action.action_test
  ]

  # Default: "DISTRIBUTED"
  # Enum: "DISTRIBUTED" "LOCAL_ONLY" "LOCAL_PREFERRED"
  # Policy for selection of endpoints from local site/remote site/both
  endpoint_selection = "LOCAL_PREFERRED"
  #Default: "ROUND_ROBIN"
  #Enum: "ROUND_ROBIN" "LEAST_REQUEST" "RING_HASH" "RANDOM" "LB_OVERRIDE"
  loadbalancer_algorithm = "ROUND_ROBIN"

  origin_servers {
    private_ip {
      ip             = var.bigip_external
      inside_network = true
      site_locator {
        site {
          namespace = "system"
          name      = volterra_azure_vnet_site.azure_site.name
        }
      }
    }

  }

  port = "8089"

  no_tls = true

}

resource "volterra_origin_pool" "elastic" {
  name      = format("%s-elastic-pool", var.name)
  namespace = var.namespace
  labels    = var.tags
  depends_on = [
    volterra_tf_params_action.action_test
  ]

  # Default: "DISTRIBUTED"
  # Enum: "DISTRIBUTED" "LOCAL_ONLY" "LOCAL_PREFERRED"
  # Policy for selection of endpoints from local site/remote site/both
  endpoint_selection = "LOCAL_PREFERRED"
  #Default: "ROUND_ROBIN"
  #Enum: "ROUND_ROBIN" "LEAST_REQUEST" "RING_HASH" "RANDOM" "LB_OVERRIDE"
  loadbalancer_algorithm = "ROUND_ROBIN"

  origin_servers {
    private_ip {
      ip             = var.bigip_external
      inside_network = true
      site_locator {
        site {
          namespace = "system"
          name      = volterra_azure_vnet_site.azure_site.name
        }
      }
    }

  }

  port = "8088"

  no_tls = true

}

resource "volterra_origin_pool" "prometheus" {
  name      = format("%s-prometheus-pool", var.name)
  namespace = var.namespace
  labels    = var.tags

  depends_on = [
    volterra_tf_params_action.action_test
  ]

  # Default: "DISTRIBUTED"
  # Enum: "DISTRIBUTED" "LOCAL_ONLY" "LOCAL_PREFERRED"
  # Policy for selection of endpoints from local site/remote site/both
  endpoint_selection = "LOCAL_PREFERRED"
  #Default: "ROUND_ROBIN"
  #Enum: "ROUND_ROBIN" "LEAST_REQUEST" "RING_HASH" "RANDOM" "LB_OVERRIDE"
  loadbalancer_algorithm = "ROUND_ROBIN"

  origin_servers {
    private_ip {
      ip             = var.bigip_external
      inside_network = true
      site_locator {
        site {
          namespace = "system"
          name      = volterra_azure_vnet_site.azure_site.name
        }
      }
    }

  }

  port = "8088"

  no_tls = true

}

resource "volterra_origin_pool" "juiceshop" {
  name      = format("%s-juiceshop-pool", var.name)
  namespace = var.namespace
  labels    = var.tags

  depends_on = [
    volterra_tf_params_action.action_test
  ]

  # Default: "DISTRIBUTED"
  # Enum: "DISTRIBUTED" "LOCAL_ONLY" "LOCAL_PREFERRED"
  # Policy for selection of endpoints from local site/remote site/both
  endpoint_selection = "LOCAL_PREFERRED"
  #Default: "ROUND_ROBIN"
  #Enum: "ROUND_ROBIN" "LEAST_REQUEST" "RING_HASH" "RANDOM" "LB_OVERRIDE"
  loadbalancer_algorithm = "ROUND_ROBIN"

  origin_servers {
    private_ip {
      ip             = var.bigip_external
      inside_network = true
      site_locator {
        site {
          namespace = "system"
          name      = volterra_azure_vnet_site.azure_site.name
        }
      }
    }

  }

  port = "443"

  use_tls {
    no_mtls                  = true
    skip_server_verification = true
    use_host_header_as_sni   = true

    tls_config {
      default_security = true
    }
  }

}

resource "volterra_origin_pool" "logstash" {
  name      = format("%s-logstash-pool", var.name)
  namespace = var.namespace
  labels    = var.tags

  depends_on = [
    volterra_tf_params_action.action_test
  ]

  # Default: "DISTRIBUTED"
  # Enum: "DISTRIBUTED" "LOCAL_ONLY" "LOCAL_PREFERRED"
  # Policy for selection of endpoints from local site/remote site/both
  endpoint_selection = "LOCAL_PREFERRED"
  #Default: "ROUND_ROBIN"
  #Enum: "ROUND_ROBIN" "LEAST_REQUEST" "RING_HASH" "RANDOM" "LB_OVERRIDE"
  loadbalancer_algorithm = "ROUND_ROBIN"

  origin_servers {
    private_ip {
      ip             = var.bigip_external
      inside_network = true
      site_locator {
        site {
          namespace = "system"
          name      = volterra_azure_vnet_site.azure_site.name
        }
      }
    }

  }

  port = "8090"

  no_tls = true

}

resource "volterra_http_loadbalancer" "kibana" {
  name      = format("%s-kibana-lb", var.name)
  namespace = var.namespace

  depends_on = [
    volterra_origin_pool.kibana
  ]

  // One of the arguments from this list "do_not_advertise advertise_on_public_default_vip advertise_on_public advertise_custom" must be set
  advertise_on_public_default_vip = true

  // One of the arguments from this list "no_challenge js_challenge captcha_challenge policy_based_challenge" must be set
  no_challenge = true

  domains = ["kibana.${var.delegated_domain}"]

  // One of the arguments from this list "round_robin least_active random source_ip_stickiness cookie_stickiness ring_hash" must be set

  round_robin = true

  // One of the arguments from this list "https_auto_cert https http" must be set

  https_auto_cert {
    add_hsts      = true
    http_redirect = true
    no_mtls       = true

  }
  // One of the arguments from this list "disable_rate_limit rate_limit" must be set
  disable_rate_limit = true
  // One of the arguments from this list "no_service_policies active_service_policies service_policies_from_namespace" must be set
  service_policies_from_namespace = true

  // One of the arguments from this list "waf waf_rule disable_waf" must be set

  disable_waf = true

  default_route_pools {
    endpoint_subsets = null
    pool {
      name      = format("%s-kibana-pool", var.name)
      namespace = var.namespace
    }
  }

}

resource "volterra_http_loadbalancer" "elastic" {
  name      = format("%s-elastic-lb", var.name)
  namespace = var.namespace

  depends_on = [
    volterra_origin_pool.elastic
  ]

  // One of the arguments from this list "do_not_advertise advertise_on_public_default_vip advertise_on_public advertise_custom" must be set
  advertise_on_public_default_vip = true

  // One of the arguments from this list "no_challenge js_challenge captcha_challenge policy_based_challenge" must be set
  no_challenge = true

  domains = ["elastic.${var.delegated_domain}"]

  // One of the arguments from this list "round_robin least_active random source_ip_stickiness cookie_stickiness ring_hash" must be set

  round_robin = true

  // One of the arguments from this list "https_auto_cert https http" must be set

  https_auto_cert {
    add_hsts      = true
    http_redirect = true
    no_mtls       = true

  }
  // One of the arguments from this list "disable_rate_limit rate_limit" must be set
  disable_rate_limit = true
  // One of the arguments from this list "no_service_policies active_service_policies service_policies_from_namespace" must be set
  service_policies_from_namespace = true

  // One of the arguments from this list "waf waf_rule disable_waf" must be set

  disable_waf = true

  default_route_pools {
    endpoint_subsets = null
    pool {
      name      = format("%s-elastic-pool", var.name)
      namespace = var.namespace
    }
  }

}
