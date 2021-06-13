resource "azurerm_storage_account" "test" {
  name                     = "jfrogstore"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "test" {
  name                 = "sharename"
  storage_account_name = azurerm_storage_account.test.name
  quota                = 10

}