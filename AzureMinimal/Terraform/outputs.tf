output "region" {
  value = var.region
}

output "dc_public_ip" {
  value = azurerm_public_ip.dc-publicip.ip_address
}


output "win10_public_ip" {
  value = azurerm_public_ip.win10-publicip.ip_address 
}
