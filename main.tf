// Tags
locals {
  tags = {
    class      = var.tag_class
    instructor = var.tag_instructor
    semester   = var.tag_semester
  }
}

// Existing Resources

/// Subscription ID

# data "azurerm_subscription" "current" {
# }

// Random Suffix Generator

resource "random_integer" "deployment_id_suffix" {
  min = 100
  max = 999
}

// Resource Group

resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.class_name}-${var.student_name}-${var.environment}-${var.location}-${random_integer.deployment_id_suffix.result}"
  location = var.location

  tags = local.tags
}

// Virtual Network
resource "azurerm_vnet" "vnet" {
  name                = "vnet-${var.class_name}-${var.student_name}-${var.environment}-${var.location}-${random_integer.deployment_id_suffix.result}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.vnet.location
  resource_group_name = azurerm_resource_group.vnet.name

  tags = local.tags
}

// Subnet
resource "azurerm_subnet" "subnet" {
  name                 = "subnet-${var.class_name}-${var.student_name}-${var.environment}-${var.location}-${random_integer.deployment_id_suffix.result}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_vnet.subnet.name
  address_prefixes     = [10.0.2.0/24]
  service_endpoints    = ["Microsoft.Sql"]

  tags = local.tags
}

resource "azurerm_mssql_server" "sqlsrvr" {
  name                         = "sqlsrvr-${var.class_name}-${var.student_name}-${var.environment}-${var.location}-${random_integer.deployment_id_suffix.result}"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"

  tags = local.tags
}

resource "azurerm_mssql_virtual_network_rule" "sqlsrvr_vnet" {
  name      = "sqlsrvr_vnet-${var.class_name}-${var.student_name}-${var.environment}-${var.location}-${random_integer.deployment_id_suffix.result}"
  server_id = azurerm_mssql_server.sqlsrvr_vnet.id
  subnet_id = azurerm_subnet.subnet.id

  tags = local.tags
}
// Storage Account

resource "azurerm_storage_account" "storage" {
  name                     = "sto${var.class_name}${var.student_name}${var.environment}${random_integer.deployment_id_suffix.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = local.tags
}

