terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
terraform {
  backend "azurerm" {}
}
}
provider "azurerm" {
  features {}
subscription_id = "de1c1815-4f90-412b-9551-d55f0de9407d"
}



