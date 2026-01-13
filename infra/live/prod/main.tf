terraform {
  backend "azurerm" {} # backend config passed via terraform init -backend-config
  required_version = ">= 1.6"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

variable "location" {
  type    = string
  default = "westeurope"
}

resource "azurerm_resource_group" "prod" {
  name     = "rg-azproj-prod"
  location = var.location
}
