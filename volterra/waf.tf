resource "volterra_waf" "default" {
  name      = "${var.namespace}-default-waf"
  namespace = var.namespace

  app_profile {}
  mode = "ALERT_ONLY"
}
