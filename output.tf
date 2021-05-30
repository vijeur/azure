
output "root_module_says" {
    value = "hello from root module"
}

output "PublicIPForLB" {
   value = azurerm_public_ip.test.*.ip_address
}