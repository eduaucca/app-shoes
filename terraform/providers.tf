terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state-us"
    storage_account_name = "tfstateappshoes9988"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
    }
}
provider "azurerm" {
  features {}
}
