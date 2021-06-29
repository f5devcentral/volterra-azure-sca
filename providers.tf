terraform {
  required_version = ">= 0.12"
  required_providers {
    volterra = {
      source  = "volterraedge/volterra"
      version = "0.7.0"
    }
  }
}

#provider azurerm {
#  version = "~> 2.30.0"
#  features {}
#}

provider "volterra" {
  api_p12_file = var.api_p12_file
  api_cert     = var.api_p12_file != "" ? "" : var.api_cert
  api_key      = var.api_p12_file != "" ? "" : var.api_key
  #api_ca_cert  = var.api_ca_cert
  url = var.url
}
