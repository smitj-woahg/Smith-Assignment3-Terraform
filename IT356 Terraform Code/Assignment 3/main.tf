# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}




#Virtual Network setup
resource "azurerm_resource_group" "Vnet-Resources" {
  name     = "network-resources"
  location = "eastus"
}

resource "azurerm_network_security_group" "InternalNSG" {
  name     = "InternalNSG"
  location = "eastus"
  resource_group_name = "network-resources"
}
resource "azurerm_network_security_group" "ExternalNSG" {
  name     = "ExternalNSG"
  location = "eastus"
  resource_group_name = "network-resources"
}

resource "azurerm_virtual_network" "UAACSMainNet" {
  name     = "UAACSMainNet"
  location = "eastus"
  resource_group_name = "network-resources"
  address_space       = ["10.0.0.0/16"]

  subnet {
    name             = "InternalNet"
    address_prefix = ["10.0.0.0/24"]
    security_group   = "InternalNSG"

  }

  subnet {
    name             = "ExternalNet"
    address_prefix = ["10.0.16.0/20"]
    security_group   = "ExternalNSG"
  }
}

resource "azurerm_network_interface" "Int1" {
  name                = "InternalInt"
  location            = "eastus"
  resource_group_name = "network-resources"

  ip_configuration {
    name                          = "internalIPconfig1"
    private_ip_address_allocation = "Dynamic"
  }
}
resource "azurerm_network_interface" "Int2" {
  name                = "InternalInt2"
  location            = "eastus"
  resource_group_name = "network-resources"

  ip_configuration {
    name                          = "internalIPconfig2"
    private_ip_address_allocation = "Dynamic"
  }
}
resource "azurerm_network_interface" "Int3" {
  name                = "ExternalInt1"
  location            = "eastus"
  resource_group_name = "network-resources"

  ip_configuration {
    name                          = "externalIPconfig1"
    private_ip_address_allocation = "Dynamic"
  }
}
resource "azurerm_network_interface" "Int4" {
  name                = "ExternalInt2"
  location            = "eastus"
  resource_group_name = "network-resources"

  ip_configuration {
    name                          = "externalIPconfig2"
    private_ip_address_allocation = "Dynamic"
  }
}


#Resource Groups for VMs
resource "azurerm_resource_group" "InternalVMs" {
  name     = "InternalVMs"
  location = "eastus"
}
resource "azurerm_resource_group" "ExternalVMs" {
  name     = "ExternalVMs"
  location = "eastus"
}

#Windows VMs
resource "azurerm_windows_virtual_machine" "DC1" {
  name                = "DC1"
  resource_group_name = "InternalVMs"
  location            = "eastus"
  size                = "D2ds_v4"
  admin_username      = "HighADMuser"
  admin_password      = "P@$$w0rd1234"
  network_interface_ids = [
    azurerm_network_interface.Int1.id
  ]
  zone = "1"

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2025-Datacenter"
    version   = "latest"
  }
}
resource "azurerm_windows_virtual_machine" "DC2" {
  name                = "DC2"
  resource_group_name = "InternalVMs"
  location            = "eastus"
  size                = "D2ds_v4"
  admin_username      = "HighADMuser"
  admin_password      = "P@$$w0rd1234"
  network_interface_ids = [
    azurerm_network_interface.Int1.id
  ]
  zone = "1"

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2025-Datacenter"
    version   = "latest"
  }
}
resource "azurerm_windows_virtual_machine" "MSCA" {
  name                = "MSCA"
  resource_group_name = "InternalVMs"
  location            = "eastus"
  size                = "D2ds_v4"
  admin_username      = "HighADMuser"
  admin_password      = "P@$$w0rd1234"
  network_interface_ids = [
    azurerm_network_interface.Int1.id
  ]
  zone = "1"

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2025-Datacenter"
    version   = "latest"
  }
}
resource "azurerm_windows_virtual_machine" "NPS" {
  name                = "NPS"
  resource_group_name = "InternalVMs"
  location            = "eastus"
  size                = "D2ds_v4"
  admin_username      = "HighADMuser"
  admin_password      = "P@$$w0rd1234"
  network_interface_ids = [
    azurerm_network_interface.Int2.id
  ]
  zone = "1"

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2025-Datacenter"
    version   = "latest"
  }
}



#Linux VMs
resource "azurerm_linux_virtual_machine" "LinuxInternal1" {
  name                = "LinuxInternal1"
  resource_group_name = "InternalVMs"
  location            = "eastus"
  size                = "D2ds_v4"
  admin_username      = "adminuser"
  admin_password      = "P@ssw0rd1234"
  network_interface_ids = [
    azurerm_network_interface.Int2.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "24_04-lts"
    version   = "latest"
  }
}
resource "azurerm_linux_virtual_machine" "LinuxInternal2" {
  name                = "LinuxInternal2"
  resource_group_name = "InternalVMs"
  location            = "eastus"
  size                = "D2ds_v4"
  admin_username      = "adminuser"
  admin_password      = "P@ssw0rd1234"
  network_interface_ids = [
    azurerm_network_interface.Int2.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "24_04-lts"
    version   = "latest"
  }
}

resource "azurerm_linux_virtual_machine" "LinuxExternal1" {
  name                = "LinuxExternal1"
  resource_group_name = "ExternalVMs"
  location            = "eastus"
  size                = "D2ds_v4"
  admin_username      = "adminuser"
  admin_password      = "P@ssw0rd1234"
  network_interface_ids = [
    azurerm_network_interface.Int3.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "24_04-lts"
    version   = "latest"
  }
}
resource "azurerm_linux_virtual_machine" "LinuxExternal2" {
  name                = "LinuxExternal2"
  resource_group_name = "ExternalVMs"
  location            = "eastus"
  size                = "D2ds_v4"
  admin_username      = "adminuser"
  admin_password      = "P@ssw0rd1234"
  network_interface_ids = [
    azurerm_network_interface.Int4.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "24_04-lts"
    version   = "latest"
  }
}



#Line structure References
# lines 1-15: https://developer.hashicorp.com/terraform/tutorials/azure-get-started/azure-build
# lines 20-55: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network
# lines 58-80: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface
# lines 92-190: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_virtual_machine
# lines 192-300: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine
