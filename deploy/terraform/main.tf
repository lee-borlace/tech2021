# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.65"
    }
  }

  backend "azurerm" {
    resource_group_name  = "lee-syd-all-arg-rwaterra"
    storage_account_name = "leesydallstarwaterra"
    container_name       = "terrastate"
    key                  = "terrastate.tfstate"
  }

  required_version = ">= 0.14.9"
}

provider "azurerm" {
  features {}
}

resource "azurerm_log_analytics_workspace" "law" {
  name                = "${var.org_name}-${var.location_abbreviation}-${var.TERRA_ENVIRONMENT_ABBREVIATION}-law-${var.solution_name}"
  location            = var.location
  resource_group_name = var.TERRA_RESOURCE_GROUP_NAME
  sku                 = "PerGB2018"
  retention_in_days   = 30
}
