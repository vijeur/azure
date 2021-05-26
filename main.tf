# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }

  required_version = ">= 0.14.9"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
 name     = var.resource_group_name
 location = var.location
}

resource "azurerm_virtual_network" "test" {
 name                = "acctvn"
 address_space       = ["10.0.0.0/16"]
 location            = azurerm_resource_group.test.location
 resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
 name                 = "acctsub"
 resource_group_name  = azurerm_resource_group.test.name
 virtual_network_name = azurerm_virtual_network.test.name
 address_prefix       = "10.0.2.0/24"
}

#resource "azurerm_subnet" "subnet02" {
# name                 = "subnet02"
# resource_group_name  = azurerm_resource_group.test.name
# virtual_network_name = azurerm_virtual_network.test.name
# address_prefix       = "10.0.3.0/24"
#}

#resource "azurerm_subnet" "subnet03" {
# name                 = "subnet03"
# resource_group_name  = azurerm_resource_group.test.name
# virtual_network_name = azurerm_virtual_network.test.name
# address_prefix       = "10.0.4.0/24"
#}

resource "azurerm_public_ip" "test" {
 name                         = "PublicIPForLB"
 location                     = azurerm_resource_group.test.location
 resource_group_name          = azurerm_resource_group.test.name
 sku                          = "Standard"
 allocation_method            = "Static"
}

resource "azurerm_lb" "test" {
 name                = "loadBalancer"
 location            = azurerm_resource_group.test.location
 resource_group_name = azurerm_resource_group.test.name
 sku                 = "Standard"

 frontend_ip_configuration {
   name                 = "PublicIPAddress"
   public_ip_address_id = azurerm_public_ip.test.id
 }
}

resource "azurerm_lb_backend_address_pool" "test" {
 resource_group_name = azurerm_resource_group.test.name
 loadbalancer_id     = azurerm_lb.test.id
 name                = "BackEndAddressPool"
}

resource "azurerm_network_interface" "test01" {
 #count               = 3
 name                = "backend_address01"
 location            = azurerm_resource_group.test.location
 resource_group_name = azurerm_resource_group.test.name

 ip_configuration {
   name                          = "testConfiguration"
   subnet_id                     = azurerm_subnet.test.id
   private_ip_address_allocation = "dynamic"
 }
}

resource "azurerm_lb_probe" "test" {
 resource_group_name = azurerm_resource_group.test.name
 loadbalancer_id     = azurerm_lb.test.id
 name                = "ssh-running-probe"
 port                = var.application_port_01
}

resource "azurerm_lb_rule" "lbnatrule" {
   resource_group_name            = azurerm_resource_group.test.name
   loadbalancer_id                = azurerm_lb.test.id
   name                           = "http"
   protocol                       = "Tcp"
   frontend_port                  = var.application_port_01
   backend_port                   = var.application_port_01
   backend_address_pool_id        = azurerm_lb_backend_address_pool.test.id
   frontend_ip_configuration_name = "PublicIPAddress"
   probe_id                       = azurerm_lb_probe.test.id
   disable_outbound_snat          = "false"
   enable_tcp_reset               = "true"
}

#resource "azurerm_lb_nat_rule" "test" {
#  resource_group_name            = azurerm_resource_group.test.name
#  loadbalancer_id                = azurerm_lb.test.id
#  name                           = "LBRule"
#  protocol                       = "Tcp"
#  frontend_port                  = 22
#  backend_port                   = 22
#  frontend_ip_configuration_name = "publicIPAddress"
#}
#
resource "azurerm_network_interface_backend_address_pool_association" "test" {
  #count                   = 1
  network_interface_id    = azurerm_network_interface.test01.id
  ip_configuration_name   = "testConfiguration"
  backend_address_pool_id = azurerm_lb_backend_address_pool.test.id
}

resource "azurerm_network_security_group" "test" {
  name                = "SecurityGroup01"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_network_security_rule" "test" {
  name                        = "sg_rule_01"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.test.name
  network_security_group_name = azurerm_network_security_group.test.name
}

resource "azurerm_network_security_rule" "test02" {
  name                        = "sg_rule_02"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.test.name
  network_security_group_name = azurerm_network_security_group.test.name
}

resource "azurerm_subnet_network_security_group_association" "test" {
  subnet_id                 = azurerm_subnet.test.id
  network_security_group_id = azurerm_network_security_group.test.id
}

resource "azurerm_managed_disk" "test" {
 #count                = 1
 name                 = "datadisk_artifacts"
 location             = azurerm_resource_group.test.location
 resource_group_name  = azurerm_resource_group.test.name
 storage_account_type = "Standard_LRS"
 create_option        = "Empty"
 disk_size_gb         = "11"
}

resource "azurerm_availability_set" "avset" {
 name                         = "avset"
 location                     = azurerm_resource_group.test.location
 resource_group_name          = azurerm_resource_group.test.name
 platform_fault_domain_count  = 3
 platform_update_domain_count = 3
 managed                      = true
}

resource "azurerm_virtual_machine" "test" {
 count                 = 1
 name                  = var.vm01
 location              = azurerm_resource_group.test.location
 availability_set_id   = azurerm_availability_set.avset.id
 resource_group_name   = azurerm_resource_group.test.name
 network_interface_ids = [azurerm_network_interface.test01.id]
 vm_size               = "Standard_DS1_v2"

 # Uncomment this line to delete the OS disk automatically when deleting the VM
 delete_os_disk_on_termination = true

 # Uncomment this line to delete the data disks automatically when deleting the VM
 delete_data_disks_on_termination = true

 storage_image_reference {
   publisher = "OpenLogic"
   offer     = "CentOS"
   sku       = "7.5"
   version   = "latest"
 }

 storage_os_disk {
   name              = "myosdisk01"
   caching           = "ReadWrite"
   create_option     = "FromImage"
   managed_disk_type = "Standard_LRS"
 }

 # Optional data disks
 storage_data_disk {
   name              = "datadisk_new_01"
   managed_disk_type = "Standard_LRS"
   create_option     = "Empty"
   lun               = 0
   disk_size_gb      = "20"
 }

 storage_data_disk {
   name            = azurerm_managed_disk.test.name
   managed_disk_id = azurerm_managed_disk.test.id
   create_option   = "Attach"
   lun             = 1
   disk_size_gb    = azurerm_managed_disk.test.disk_size_gb
 }

 os_profile {
   computer_name  = var.vm01
   admin_username = "testadmin"
   admin_password = "Password1234!"
   custom_data    = file("azure-user-data.sh")
 }

 os_profile_linux_config {
   disable_password_authentication = false
 }

 tags = {
   environment = "staging"
 }
}

#resource "azurerm_postgresql_server" "test" {
#  name                = "test-psqlserver"
#  location            = azurerm_resource_group.test.location
#  resource_group_name = azurerm_resource_group.test.name
#
#  administrator_login          = "psqladminun"
#  administrator_login_password = "H@Sh1CoR3!"
#
#  sku_name   = "GP_Gen5_4"
#  version    = "9.6"
#  storage_mb = 10240
#
#  backup_retention_days        = 7
#  geo_redundant_backup_enabled = true
#  auto_grow_enabled            = true
#
#  public_network_access_enabled    = false
#  ssl_enforcement_enabled          = true
#  ssl_minimal_tls_version_enforced = "TLS1_2"
#}
