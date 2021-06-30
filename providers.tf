terraform {
  required_version = ">= 0.12"
  required_providers {
    volterrarm = {
      source  = "volterraedge/volterra"
      version = "0.7.0"
    }
    azurerm = {
      version = "~> 2.30.0"
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  volterra_config = {
    api_p12_file = var.api_p12_file
    api_cert     = var.api_p12_file != "" ? "" : var.api_cert
    api_key      = var.api_p12_file != "" ? "" : var.api_key
    url          = var.api_url
  }
}

provider "volterrarm" {
  api_p12_file = var.api_p12_file
  api_cert     = var.api_p12_file != "" ? "" : var.api_cert
  api_key      = var.api_p12_file != "" ? "" : var.api_key
  url          = var.api_url
}
