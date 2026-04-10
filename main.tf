provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "weather-rg"
  location = "East US"
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "weather-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1s"
  admin_username      = "azureuser"
  admin_password      = "Password@1234"
  disable_password_authentication = false

  network_interface_ids = []

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}