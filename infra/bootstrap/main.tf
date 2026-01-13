terraform {
  required_version = ">= 1.6"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
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

variable "prefix" {
  type    = string
  default = "azproj"
}

resource "azurerm_resource_group" "tfstate" {
  name     = "rg-${var.prefix}-tfstate"
  location = var.location
}

resource "random_string" "sa" {
  length  = 6
  special = false
  upper   = false
}

# Storage account name must be globally unique, lowercase, 3-24 chars
resource "azurerm_storage_account" "tfstate" {
  name                     = "st${var.prefix}${random_string.sa.result}"
  resource_group_name      = azurerm_resource_group.tfstate.name
  location                 = azurerm_resource_group.tfstate.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # cheap + sane defaults
  min_tls_version          = "TLS1_2"
  allow_nested_items_to_be_public = false
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "private"
}

output "tfstate_rg"        { value = azurerm_resource_group.tfstate.name }
output "tfstate_sa"        { value = azurerm_storage_account.tfstate.name }
output "tfstate_container" { value = azurerm_storage_container.tfstate.name }
