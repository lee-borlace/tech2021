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
  name                = "${var.org_name}-${var.location_abbreviation}-${var.environment_abbreviation}-law-${var.solution_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_app_service_plan" "asp" {
  name                = "${var.org_name}-${var.location_abbreviation}-${var.environment_abbreviation}-asp-${var.solution_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = "Linux"

  sku {
    tier = "Basic"
    size = "B1"
  }
}

resource "azurerm_app_service" "web" {
  name                = "${var.org_name}-${var.location_abbreviation}-${var.environment_abbreviation}-web-${var.solution_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  app_service_plan_id = azurerm_app_service_plan.asp.id

  site_config {
    dotnet_framework_version = "v4.0"
  }

  app_settings = {
    "SOME_KEY" = "some-value"
  }

}
