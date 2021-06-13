resource "azurerm_mssql_server" "msql" {
  name                         = "${var.platform}-${var.environment}-sql-server01"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "sqluser"
  administrator_login_password = "DxHCB46w8k5B"
  #public_network_access_enabled = false

  tags = {
    Name = "${var.platform}_${var.environment}_sql_server"
    Platform = "${var.platform}"
    Owner = "${var.owner}"
    Environment = "${var.environment}"
  }
}

resource "azurerm_mssql_database" "test" {
  depends_on          = [azurerm_mssql_server.msql]
  name                = "${var.platform}-${var.environment}-db-01"
  server_id           = azurerm_mssql_server.msql.id
  collation           = "Latin1_General_CS_AI"
  zone_redundant      = false
  read_scale          = false

  tags = {
    Name = "${var.platform}_${var.environment}_sql_db"
    Platform = "${var.platform}"
    Owner = "${var.owner}"
    Environment = "${var.environment}"
  }
}

#resource "azurerm_private_endpoint" "test" {
#  depends_on          = [azurerm_mssql_server.msql]
#  name                = "${var.platform}-${var.environment}-sql-endpoint-01"
#  location            = azurerm_resource_group.test.location
#  resource_group_name = azurerm_resource_group.test.name
#  subnet_id           = azurerm_subnet.test.id
#
#  private_service_connection {
#    name                           = "${var.platform}-${var.environment}-pvt-endpoint-01"
#    private_connection_resource_id = azurerm_mssql_server.msql.id
#    subresource_names              = [ "sqlServer" ]
#    is_manual_connection           = false
#  }
#}

# Create a DB Private Endpoint
resource "azurerm_private_endpoint" "test01" {
  depends_on = [azurerm_mssql_server.msql]
  name = "kopi-sql-db-endpoint"
  location = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  subnet_id = azurerm_subnet.test.id
  private_service_connection {
    name = "kopi-sql-db-endpoint"
    is_manual_connection = "false"
    private_connection_resource_id = azurerm_mssql_server.msql.id
    subresource_names = ["sqlServer"]
  }
}
# DB Private Endpoint Connecton
data "azurerm_private_endpoint_connection" "kopi-endpoint-connection" {
  depends_on = [azurerm_private_endpoint.test01]
  name = azurerm_private_endpoint.test01.name
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_sql_firewall_rule" "test" {
  name                = "FirewallRule1"
  resource_group_name = azurerm_resource_group.test.name
  server_name         = azurerm_mssql_server.msql.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}