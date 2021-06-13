
resource "azurerm_network_interface" "test01" {
 #count               = 3
 name                = "${var.platform}-${var.environment}-backend-add-01"
 location            = azurerm_resource_group.test.location
 resource_group_name = azurerm_resource_group.test.name

 ip_configuration {
   name                          = "testConfiguration01"
   subnet_id                     = azurerm_subnet.test.id
   private_ip_address_allocation = "static"
   private_ip_address            = "${cidrhost(azurerm_subnet.test.address_prefix, 5)}"
 }
}

resource "azurerm_virtual_machine" "test" {
 #count                 = 1
 name                  = "${var.platform}-${var.environment}-vm-01"
 location              = azurerm_resource_group.test.location
 availability_set_id   = azurerm_availability_set.avset.id
 resource_group_name   = azurerm_resource_group.test.name
 network_interface_ids = [azurerm_network_interface.test01.id]
 vm_size               = "Standard_DS1_v2"
 depends_on = [azurerm_storage_account.test]
 # Uncomment this line to delete the OS disk automatically when deleting the VM
 delete_os_disk_on_termination = true

 # Uncomment this line to delete the data disks automatically when deleting the VM
 delete_data_disks_on_termination = true

 storage_image_reference {
   publisher = "Canonical"
   offer     = "UbuntuServer"
   sku       = "16.04-LTS"
   version   = "latest"
 }

 storage_os_disk {
   name              = "${var.platform}-${var.environment}-vm-disk-01"
   caching           = "ReadWrite"
   create_option     = "FromImage"
   managed_disk_type = "Standard_LRS"
 }

 # Optional data disks
 #storage_data_disk {
 #  name              = "datadisk_new_01"
 #  managed_disk_type = "Standard_LRS"
 #  create_option     = "Empty"
 #  lun               = 0
 #  disk_size_gb      = "20"
 #}

# storage_data_disk {
#   name            = azurerm_managed_disk.test.name
#   managed_disk_id = azurerm_managed_disk.test.id
#   create_option   = "Attach"
#   lun             = 0
#   disk_size_gb    = azurerm_managed_disk.test.disk_size_gb
# }

 os_profile {
   computer_name  = "${var.platform}-${var.environment}-vm-01"
   admin_username = "testadmin"
   admin_password = "Password1234!"
   #custom_data    = file("azure-user-data.sh")
   custom_data    = <<-EOF
          #!/bin/bash
          
          echo "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64" >> /etc/environment
          echo "export JFROG_HOME=/opt/jfrog" >> /etc/environment
          #apt install postgresql-client-9.5 -y
          
          EOF
  
 }

 os_profile_linux_config {
   disable_password_authentication = true
   ssh_keys {
   key_data = file("./keys/ssh_key.pub")
   path = "/home/testadmin/.ssh/authorized_keys"
   }

 }

  tags = {
    Name = "${var.platform}_${var.environment}_vitual_machine_01"
    Platform = "${var.platform}"
    Owner = "${var.owner}"
    Environment = "${var.environment}"
  }
}

resource "azurerm_virtual_machine_extension" "test" {
    #resource_group_name     = azurerm_resource_group.test.name
    #location                = azurerm_resource_group.test.location
    name                    = "${var.platform}-${var.environment}-vm-ext-01"
    virtual_machine_id      = azurerm_virtual_machine.test.id
    #virtual_machine_name = var.vm01
    publisher            = "Microsoft.Azure.Extensions"
    type                 = "CustomScript"
    type_handler_version = "2.0"

    protected_settings = <<PROT
    {
        "script": "${base64encode(file(var.scfile))}"
    }
    PROT
}
