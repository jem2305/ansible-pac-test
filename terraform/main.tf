variable "ARM_SUBSCRIPTION_ID" {
  type = string
  sensitive = true
}

variable "ARM_CLIENT_ID" {
  type = string
  sensitive = true
}

variable "ARM_TENANT_ID" {
  type = string
  sensitive = true
}

variable "ARM_CLIENT_SECRET" {
  type = string
  sensitive = true
}

provider "azurerm" {
  features { }
  subscription_id = var.ARM_SUBSCRIPTION_ID
  client_id       = var.ARM_CLIENT_ID
  tenant_id       = var.ARM_TENANT_ID
  client_secret   = var.ARM_CLIENT_SECRET
}

resource "azurerm_resource_group" "main" {
  name     = "ansible-test-resources"
  location = "eastus"
  # tags = {
  #   "Cost-Center" = "HR Department"
  # }
}