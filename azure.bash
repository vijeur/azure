#!/bin/bash

sudo mkdir -p /mnt/${data.azurerm_storage_account.storage-accoun.name}/${data.azurerm_storage_share.test.name}
sudo mount -t cifs //${data.azurerm_storage_account.storage-account.name}.file.core.windows.net/${data.azurerm_storage_share.test.name} /mnt/${data.azurerm_storage_account.storage-account.name}/share -o vers=3.0,dir_mode=0755,file_mode=0755,serverino,username=${data.azurerm_storage_account.storage-account.name},password=${data.azurerm_storage_account.storage-account.primary_access_key}
sudo echo "${data.azurerm_storage_account.storage-accoun.name} >> /tmp/abc"
sudo echo "${data.azurerm_storage_account.storage-account.primary_access_key} >> /tmp/password"