########################################################################################
# Configure the Azure provider
########################################################################################

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
 name     = "${var.platform}-${var.environment}-resource-01"
 location = var.location
}

########################################################################################
# Configure the networks
########################################################################################

resource "azurerm_virtual_network" "test" {
 name                = "${var.platform}-${var.environment}-vir-net-01"
 address_space       = ["10.0.0.0/16"]
 location            = azurerm_resource_group.test.location
 resource_group_name = azurerm_resource_group.test.name

  tags = {
    Name = "${var.platform}_${var.environment}_vitual_net"
    Platform = "${var.platform}"
    Owner = "${var.owner}"
    Environment = "${var.environment}"
  }

}

resource "azurerm_subnet" "test" {
 name                 = "${var.platform}-${var.environment}-subnet-01"
 resource_group_name  = azurerm_resource_group.test.name
 virtual_network_name = azurerm_virtual_network.test.name
 address_prefixes       = ["10.0.2.0/24"]
 enforce_private_link_endpoint_network_policies = true
 enforce_private_link_service_network_policies = true
 service_endpoints    = ["Microsoft.Sql"]
}

########################################################################################
# Create a Public IP for LB
########################################################################################

resource "azurerm_public_ip" "test" {
 name                         = "${var.platform}-${var.environment}-pub-ip-01"
 location                     = azurerm_resource_group.test.location
 resource_group_name          = azurerm_resource_group.test.name
 sku                          = "Standard"
 allocation_method            = "Static"
}

########################################################################################
# Create a Load Balancer
########################################################################################

resource "azurerm_lb" "test" {
 name                = "${var.platform}-${var.environment}-lb-01"
 location            = azurerm_resource_group.test.location
 resource_group_name = azurerm_resource_group.test.name
 sku                 = "Standard"

 frontend_ip_configuration {
   name                 = "PublicIPAddress"
   public_ip_address_id = azurerm_public_ip.test.id
 }
}

resource "azurerm_lb_backend_address_pool" "test" {
 #resource_group_name = azurerm_resource_group.test.name
 loadbalancer_id     = azurerm_lb.test.id
 name                = "${var.platform}-${var.environment}-back-pool-01"
}

resource "azurerm_lb_probe" "test" {
 resource_group_name = azurerm_resource_group.test.name
 loadbalancer_id     = azurerm_lb.test.id
 name                = "${var.platform}-${var.environment}-lb-probe-01"
 port                = var.lb_front_01
}

resource "azurerm_lb_rule" "lbsshrule" {
   resource_group_name            = azurerm_resource_group.test.name
   loadbalancer_id                = azurerm_lb.test.id
   name                           = "${var.platform}-${var.environment}-lb-rule-01"
   protocol                       = "Tcp"
   frontend_port                  = var.lb_front_01
   backend_port                   = var.lb_front_01
   backend_address_pool_id        = azurerm_lb_backend_address_pool.test.id
   frontend_ip_configuration_name = "PublicIPAddress"
   probe_id                       = azurerm_lb_probe.test.id
   disable_outbound_snat          = "false"
   enable_tcp_reset               = "true"
}

resource "azurerm_lb_rule" "lbhttprule" {
   resource_group_name            = azurerm_resource_group.test.name
   loadbalancer_id                = azurerm_lb.test.id
   name                           = "${var.platform}-${var.environment}-lb-rule-02"
   protocol                       = "Tcp"
   frontend_port                  = var.lb_front_02
   backend_port                   = var.lb_backnd_02
   backend_address_pool_id        = azurerm_lb_backend_address_pool.test.id
   frontend_ip_configuration_name = "PublicIPAddress"
   probe_id                       = azurerm_lb_probe.test.id
   disable_outbound_snat          = "false"
   enable_tcp_reset               = "true"
}

resource "azurerm_lb_rule" "lbhttprule03" {
   resource_group_name            = azurerm_resource_group.test.name
   loadbalancer_id                = azurerm_lb.test.id
   name                           = "${var.platform}-${var.environment}-lb-rule-03"
   protocol                       = "Tcp"
   frontend_port                  = var.lb_front_03
   backend_port                   = var.lb_backnd_03
   backend_address_pool_id        = azurerm_lb_backend_address_pool.test.id
   frontend_ip_configuration_name = "PublicIPAddress"
   probe_id                       = azurerm_lb_probe.test.id
   disable_outbound_snat          = "false"
   enable_tcp_reset               = "true"
}

resource "azurerm_network_interface_backend_address_pool_association" "test01" {
  #count                   = 1
  network_interface_id    = azurerm_network_interface.test01.id
  ip_configuration_name   = "testConfiguration01"
  backend_address_pool_id = azurerm_lb_backend_address_pool.test.id
}

########################################################################################
# Create a security group and rules
########################################################################################

resource "azurerm_network_security_group" "test" {
  name                = "${var.platform}-${var.environment}-sg-01"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_network_security_rule" "test"  {
  name                        = "${var.platform}-${var.environment}-sg-rule-01"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.test.name
  network_security_group_name = azurerm_network_security_group.test.name
  }

resource "azurerm_network_security_rule" "test02" {
  name                        = "${var.platform}-${var.environment}-sg-rule-02"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
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

########################################################################################
# Create an availability set
########################################################################################

resource "azurerm_availability_set" "avset" {
 name                         = "${var.platform}-${var.environment}-av-set-01"
 location                     = azurerm_resource_group.test.location
 resource_group_name          = azurerm_resource_group.test.name
 platform_fault_domain_count  = 1
 platform_update_domain_count = 1
 managed                      = true
}

# generate inventory file for Ansible
resource "local_file" "hosts_cfg" {
  content = templatefile("${path.module}/hosts.tpl",
    {
      test_clients = azurerm_public_ip.test.*.ip_address
    }
  )
  filename = "./hosts.cfg"
}
