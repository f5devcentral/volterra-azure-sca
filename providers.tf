terraform {
  required_version = ">= 0.13"
  required_providers {
    volterra = {
      source  = "volterraedge/volterra"
      version = "0.8.1"
    }
    azurerm = {
      version = "~> 2.30.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "2.1.0"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

provider "volterra" {
  api_p12_file = "../../mcn-demo2.p12"
  # url          = var.api_url
  # api_p12_file = var.api_p12_file
  # api_cert     = var.api_p12_file != "" ? "" : var.api_cert
  # api_key      = var.api_p12_file != "" ? "" : var.api_key
  url = var.api_url
}

provider "http" {
}
