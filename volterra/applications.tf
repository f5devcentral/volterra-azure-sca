
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
  loadbalancer_algorithm = "LEAST_REQUEST"

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

  port = "5601"

  no_tls = true

}

resource "volterra_origin_pool" "elastic_json" {
  name      = format("%s-elastic-json-pool", var.name)
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
  loadbalancer_algorithm = "LEAST_REQUEST"

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

  port = "9200"

  no_tls = true

}
resource "volterra_origin_pool" "elastic_transport" {
  name      = format("%s-elastic-transport-pool", var.name)
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
  loadbalancer_algorithm = "LEAST_REQUEST"

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

  port = "9300"

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
  loadbalancer_algorithm = "LEAST_REQUEST"

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

  port = "9090"

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
  loadbalancer_algorithm = "LEAST_REQUEST"

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

resource "volterra_origin_pool" "logstash_beats" {
  name      = format("%s-logstash-beats-pool", var.name)
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
  loadbalancer_algorithm = "LEAST_REQUEST"

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

  port = "5044"

  no_tls = true

}

resource "volterra_origin_pool" "logstash_api" {
  name      = format("%s-logstash-api-pool", var.name)
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
  loadbalancer_algorithm = "LEAST_REQUEST"

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

  port = "9600"

  no_tls = true

}

resource "volterra_user_identification" "user_identification" {
  name      = format("%s-user-ident", var.name)
  namespace = var.namespace

  rules {
    // One of the arguments from this list "client_ip query_param_key http_header_name cookie_name none client_asn" must be set
    client_ip = true
  }
}


resource "volterra_http_loadbalancer" "kibana" {
  name      = format("%s-kibana-lb", var.name)
  namespace = var.namespace

  depends_on = [
    volterra_tf_params_action.action_test, volterra_origin_pool.kibana
  ]

  // One of the arguments from this list "do_not_advertise advertise_on_public_default_vip advertise_on_public advertise_custom" must be set
  advertise_on_public_default_vip = true

  // One of the arguments from this list "no_challenge js_challenge captcha_challenge policy_based_challenge" must be set
  no_challenge = true

  domains = ["kibana.${var.delegated_domain}"]

  // One of the arguments from this list "round_robin least_active random source_ip_stickiness cookie_stickiness ring_hash" must be set

  round_robin = true

  // One of the arguments from this list "https_auto_cert https http" must be set

  //Stop waisting certs for testing!
  http {
    dns_volterra_managed = true
  }

  # https_auto_cert {
  #   add_hsts      = true
  #   http_redirect = true
  #   no_mtls       = true

  # }

  // One of the arguments from this list "disable_rate_limit rate_limit" must be set
  disable_rate_limit = true
  // One of the arguments from this list "no_service_policies active_service_policies service_policies_from_namespace" must be set
  service_policies_from_namespace = true

  single_lb_app {
    // One of the arguments from this list "enable_discovery disable_discovery" must be set

    enable_discovery {
      // One of the arguments from this list "disable_learn_from_redirect_traffic enable_learn_from_redirect_traffic" must be set
      disable_learn_from_redirect_traffic = true
    }

    // One of the arguments from this list "enable_ddos_detection disable_ddos_detection" must be set
    enable_ddos_detection = true

    // One of the arguments from this list "enable_malicious_user_detection disable_malicious_user_detection" must be set
    enable_malicious_user_detection = true
  }

  single_lb_app {
    // One of the arguments from this list "enable_discovery disable_discovery" must be set

    enable_discovery {
      // One of the arguments from this list "disable_learn_from_redirect_traffic enable_learn_from_redirect_traffic" must be set
      disable_learn_from_redirect_traffic = true
    }

    // One of the arguments from this list "enable_ddos_detection disable_ddos_detection" must be set
    enable_ddos_detection = true

    // One of the arguments from this list "enable_malicious_user_detection disable_malicious_user_detection" must be set
    enable_malicious_user_detection = true
  }

  // One of the arguments from this list "user_id_client_ip user_identification" must be set

  user_identification {
    name      = format("%s-user-ident", var.name)
    namespace = var.namespace
    #tenant    = var.tenant
  }

  // One of the arguments from this list "waf waf_rule disable_waf" must be set

  #disable_waf = true
  waf {
    namespace = var.namespace
    name      = "${var.namespace}-default-waf"
  }

  default_route_pools {
    endpoint_subsets = null
    pool {
      name      = format("%s-kibana-pool", var.name)
      namespace = var.namespace
    }
  }

}

resource "volterra_http_loadbalancer" "elastic_json" {
  name      = format("%s-elastic-json-lb", var.name)
  namespace = var.namespace

  depends_on = [
    volterra_tf_params_action.action_test, volterra_origin_pool.elastic_json
  ]

  // One of the arguments from this list "do_not_advertise advertise_on_public_default_vip advertise_on_public advertise_custom" must be set
  advertise_on_public_default_vip = true

  // One of the arguments from this list "no_challenge js_challenge captcha_challenge policy_based_challenge" must be set
  no_challenge = true

  domains = ["elastic.${var.delegated_domain}"]

  // One of the arguments from this list "round_robin least_active random source_ip_stickiness cookie_stickiness ring_hash" must be set

  round_robin = true

  // One of the arguments from this list "https_auto_cert https http" must be set

  //Stop waisting certs for testing!
  http {
    dns_volterra_managed = true
  }

  # https_auto_cert {
  #   add_hsts      = true
  #   http_redirect = true
  #   no_mtls       = true

  # }
  // One of the arguments from this list "disable_rate_limit rate_limit" must be set
  disable_rate_limit = true
  // One of the arguments from this list "no_service_policies active_service_policies service_policies_from_namespace" must be set
  service_policies_from_namespace = true

  single_lb_app {
    // One of the arguments from this list "enable_discovery disable_discovery" must be set

    enable_discovery {
      // One of the arguments from this list "disable_learn_from_redirect_traffic enable_learn_from_redirect_traffic" must be set
      disable_learn_from_redirect_traffic = true
    }

    // One of the arguments from this list "enable_ddos_detection disable_ddos_detection" must be set
    enable_ddos_detection = true

    // One of the arguments from this list "enable_malicious_user_detection disable_malicious_user_detection" must be set
    enable_malicious_user_detection = true
  }

  user_identification {
    name      = format("%s-user-ident", var.name)
    namespace = var.namespace
    #tenant    = var.tenant
  }

  // One of the arguments from this list "waf waf_rule disable_waf" must be set

  #disable_waf = true
  waf {
    namespace = var.namespace
    name      = "${var.namespace}-default-waf"
  }

  default_route_pools {
    endpoint_subsets = null
    pool {
      name      = format("%s-elastic-json-pool", var.name)
      namespace = var.namespace
    }
  }

}

resource "volterra_http_loadbalancer" "prometheus" {
  name      = format("%s-prometheus-lb", var.name)
  namespace = var.namespace

  depends_on = [
    volterra_tf_params_action.action_test, volterra_origin_pool.prometheus
  ]

  // One of the arguments from this list "do_not_advertise advertise_on_public_default_vip advertise_on_public advertise_custom" must be set
  advertise_on_public_default_vip = true

  // One of the arguments from this list "no_challenge js_challenge captcha_challenge policy_based_challenge" must be set
  no_challenge = true

  domains = ["prometheus.${var.delegated_domain}"]

  // One of the arguments from this list "round_robin least_active random source_ip_stickiness cookie_stickiness ring_hash" must be set

  round_robin = true

  // One of the arguments from this list "https_auto_cert https http" must be set

  //Stop waisting certs for testing!
  http {
    dns_volterra_managed = true
  }

  # https_auto_cert {
  #   add_hsts      = true
  #   http_redirect = true
  #   no_mtls       = true

  # }
  // One of the arguments from this list "disable_rate_limit rate_limit" must be set
  disable_rate_limit = true
  // One of the arguments from this list "no_service_policies active_service_policies service_policies_from_namespace" must be set
  service_policies_from_namespace = true

  single_lb_app {
    // One of the arguments from this list "enable_discovery disable_discovery" must be set

    enable_discovery {
      // One of the arguments from this list "disable_learn_from_redirect_traffic enable_learn_from_redirect_traffic" must be set
      disable_learn_from_redirect_traffic = true
    }

    // One of the arguments from this list "enable_ddos_detection disable_ddos_detection" must be set
    enable_ddos_detection = true

    // One of the arguments from this list "enable_malicious_user_detection disable_malicious_user_detection" must be set
    enable_malicious_user_detection = true
  }

  user_identification {
    name      = format("%s-user-ident", var.name)
    namespace = var.namespace
    #tenant    = var.tenant
  }

  // One of the arguments from this list "waf waf_rule disable_waf" must be set

  #disable_waf = true
  waf {
    namespace = var.namespace
    name      = "${var.namespace}-default-waf"
  }

  default_route_pools {
    endpoint_subsets = null
    pool {
      name      = format("%s-prometheus-pool", var.name)
      namespace = var.namespace
    }
  }

}

resource "volterra_http_loadbalancer" "logstash_api" {
  name      = format("%s-logstash-api-lb", var.name)
  namespace = var.namespace

  depends_on = [
    volterra_tf_params_action.action_test, volterra_origin_pool.logstash_api
  ]

  // One of the arguments from this list "do_not_advertise advertise_on_public_default_vip advertise_on_public advertise_custom" must be set
  advertise_on_public_default_vip = true

  // One of the arguments from this list "no_challenge js_challenge captcha_challenge policy_based_challenge" must be set
  no_challenge = true

  domains = ["logstash.${var.delegated_domain}"]

  // One of the arguments from this list "round_robin least_active random source_ip_stickiness cookie_stickiness ring_hash" must be set

  round_robin = true

  // One of the arguments from this list "https_auto_cert https http" must be set

  //Stop waisting certs for testing!
  http {
    dns_volterra_managed = true
  }

  # https_auto_cert {
  #   add_hsts      = true
  #   http_redirect = true
  #   no_mtls       = true

  # }
  // One of the arguments from this list "disable_rate_limit rate_limit" must be set
  disable_rate_limit = true
  // One of the arguments from this list "no_service_policies active_service_policies service_policies_from_namespace" must be set
  service_policies_from_namespace = true

  single_lb_app {
    // One of the arguments from this list "enable_discovery disable_discovery" must be set

    enable_discovery {
      // One of the arguments from this list "disable_learn_from_redirect_traffic enable_learn_from_redirect_traffic" must be set
      disable_learn_from_redirect_traffic = true
    }

    // One of the arguments from this list "enable_ddos_detection disable_ddos_detection" must be set
    enable_ddos_detection = true

    // One of the arguments from this list "enable_malicious_user_detection disable_malicious_user_detection" must be set
    enable_malicious_user_detection = true
  }

  user_identification {
    name      = format("%s-user-ident", var.name)
    namespace = var.namespace
    #tenant    = var.tenant
  }

  // One of the arguments from this list "waf waf_rule disable_waf" must be set

  #disable_waf = true
  waf {
    namespace = var.namespace
    name      = "${var.namespace}-default-waf"
  }

  default_route_pools {
    endpoint_subsets = null
    pool {
      name      = format("%s-logstash-api-pool", var.name)
      namespace = var.namespace
    }
  }

}

resource "volterra_http_loadbalancer" "juiceshop" {
  name      = format("%s-juice-lb", var.name)
  namespace = var.namespace

  depends_on = [
    volterra_tf_params_action.action_test, volterra_origin_pool.juiceshop
  ]

  // One of the arguments from this list "do_not_advertise advertise_on_public_default_vip advertise_on_public advertise_custom" must be set
  advertise_on_public_default_vip = true

  // One of the arguments from this list "no_challenge js_challenge captcha_challenge policy_based_challenge" must be set
  no_challenge = true

  domains = ["juice.${var.delegated_domain}"]

  // One of the arguments from this list "round_robin least_active random source_ip_stickiness cookie_stickiness ring_hash" must be set

  round_robin = true

  // One of the arguments from this list "https_auto_cert https http" must be set

  //Stop waisting certs for testing!
  http {
    dns_volterra_managed = true
  }

  # https_auto_cert {
  #   add_hsts      = true
  #   http_redirect = true
  #   no_mtls       = true

  # }
  // One of the arguments from this list "disable_rate_limit rate_limit" must be set
  disable_rate_limit = true
  // One of the arguments from this list "no_service_policies active_service_policies service_policies_from_namespace" must be set
  service_policies_from_namespace = true

  single_lb_app {
    // One of the arguments from this list "enable_discovery disable_discovery" must be set

    enable_discovery {
      // One of the arguments from this list "disable_learn_from_redirect_traffic enable_learn_from_redirect_traffic" must be set
      disable_learn_from_redirect_traffic = true
    }

    // One of the arguments from this list "enable_ddos_detection disable_ddos_detection" must be set
    enable_ddos_detection = true

    // One of the arguments from this list "enable_malicious_user_detection disable_malicious_user_detection" must be set
    enable_malicious_user_detection = true
  }
  user_identification {
    name      = format("%s-user-ident", var.name)
    namespace = var.namespace
    #tenant    = var.tenant
  }
  // One of the arguments from this list "waf waf_rule disable_waf" must be set

  #disable_waf = true
  waf {
    namespace = var.namespace
    name      = "${var.namespace}-default-waf"
  }

  default_route_pools {
    endpoint_subsets = null
    pool {
      name      = format("%s-juiceshop-pool", var.name)
      namespace = var.namespace
    }
  }

}
