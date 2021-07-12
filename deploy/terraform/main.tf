# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.65"
    }
  }

  backend "azurerm" {
    resource_group_name  = "${var.backend_resource_group_name}"
    storage_account_name = "${var.backend_storage_account_name}"
    container_name       = "terrastate"
    key                  = "terrastate.tfstate"
  }

  required_version = ">= 0.14.9"
}

provider "azurerm" {
  features {}
}

resource "azurerm_log_analytics_workspace" "law" {
  name                = "${var.org_name}-${var.location_abbreviation}-${var.environment_abbreviation}-law-${var.solution_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}
