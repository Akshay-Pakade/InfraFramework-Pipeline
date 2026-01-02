terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
 backend "azurerm" {
    resource_group_name  = "dev-resource-group"
    storage_account_name = "devinfrastorage9810"
    container_name       = "jenkins"
    key                  = "jioinfra.tfstate"
  }
  }
provider "azurerm" {
  features {}
subscription_id = "de1c1815-4f90-412b-9551-d55f0de9407d"
}




