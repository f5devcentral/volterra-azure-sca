
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
  endpoint_selection = "LOCAL_ONLY"
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
  endpoint_selection = "LOCAL_ONLY"
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
  endpoint_selection = "LOCAL_ONLY"
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
  endpoint_selection = "LOCAL_ONLY"
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
  endpoint_selection = "LOCAL_ONLY"
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

resource "volterra_http_loadbalancer" "juiceshop" {
  name      = format("%s-juice-lb", var.name)
  namespace = var.namespace

  depends_on = [
    volterra_origin_pool.juiceshop
  ]

  // One of the arguments from this list "do_not_advertise advertise_on_public_default_vip advertise_on_public advertise_custom" must be set
  advertise_on_public_default_vip = true

  // One of the arguments from this list "no_challenge js_challenge captcha_challenge policy_based_challenge" must be set
  no_challenge = true

  domains = ["juice.${var.delegated_domain}"]

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
      name      = format("%s-juiceshop-pool", var.name)
      namespace = var.namespace
    }
  }

}
