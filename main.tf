terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.60.0"
    }
  }
  backend "azurerm" {
    resource_group_name = "task-board-vasko"
    storage_account_name = "taskstoragevasko"
    container_name = "taskboardcontainer"
    key = "terraform.tfstate"
    
  }
}

provider "azurerm" {
  features {

  }
}
resource "random_integer" "ri" {
  min = 10000
  max = 99999
}

resource "azurerm_resource_group" "taskboardrg" {
  name     = "${var.resource_group_name}${random_integer.ri.result}"
  location = var.resource_group_location
}

resource "azurerm_service_plan" "azureserviceplan" {
  name                = "${var.service_plan_name}-${random_integer.ri.result}"
  location            = azurerm_resource_group.taskboardrg.location
  resource_group_name = azurerm_resource_group.taskboardrg.name
  os_type             = "Linux"
  sku_name            = "F1"
}

resource "azurerm_linux_web_app" "webapp" {
  name                = var.app_service_name
  resource_group_name = azurerm_resource_group.taskboardrg.name
  location            = azurerm_resource_group.taskboardrg.location
  service_plan_id     = azurerm_service_plan.azureserviceplan.id

  site_config {
    application_stack {
      dotnet_version = "6.0"
    }
    always_on = false
  }
  connection_string {
    name  = "DefaultConnection"
    type  = "SQLAzure"
    value = "Data Source=tcp:${azurerm_mssql_server.dbserver.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.db.name};UserID=${azurerm_mssql_server.dbserver.administrator_login};Password=${azurerm_mssql_server.dbserver.administrator_login_password};Trusted_Connection=False;MultipleActiveResultSets=True;"
  }
}

resource "azurerm_app_service_source_control" "azsourcecontrol" {
  app_id                 = azurerm_linux_web_app.webapp.id
  repo_url               = var.repo_url
  branch                 = "main"
  use_manual_integration = true
}

resource "azurerm_mssql_server" "dbserver" {
  name                         = "${var.sql_server_name}${random_integer.ri.result}"
  resource_group_name          = azurerm_resource_group.taskboardrg.name
  location                     = azurerm_resource_group.taskboardrg.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_login
  administrator_login_password = var.sql_admin_password

}

resource "azurerm_mssql_database" "db" {
  name         = "${var.sql_database_name}${random_integer.ri.result}"
  server_id    = azurerm_mssql_server.dbserver.id
  collation    = "SQL_Latin1_General_CP1_CI_AS"
  license_type = "LicenseIncluded"
  sku_name       = "S0"
  zone_redundant = false
}


resource "azurerm_mssql_firewall_rule" "firewallrule" {
  name             = "${var.firewall_rule_name}${random_integer.ri.result}"
  server_id        = azurerm_mssql_server.dbserver.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}