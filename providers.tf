terraform {
  required_version = ">= 0.13"
  required_providers {
    volterra = {
      source  = "volterraedge/volterra"
      version = "0.7.0"
    }
    http = {
      source = "hashicorp/http"
    }
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

provider azurerm {
  #version = "~> 2.30.0"
  features {}
}
