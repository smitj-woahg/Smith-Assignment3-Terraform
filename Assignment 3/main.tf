# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.14.0"
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

    security_rule {
    name                       = "Allow-Inbound-IPsec"
    priority                   = 1010
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "500, 4500"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
    security_rule {
    name                       = "Allow-Outbound-IPsec"
    priority                   = 1010
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "500, 4500"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
    security_rule {
    name                       = "Default-Block-In"
    priority                   = 1020
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "0-65535"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
    security_rule {
    name                       = "Default-Block-Out"
    priority                   = 1020
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "0-65535"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}
resource "azurerm_network_security_group" "ExternalNSG" {
  name     = "ExternalNSG"
  location = "eastus"
  resource_group_name = "network-resources"

  security_rule {
    name                       = "Allow-Inbound-IPsec"
    priority                   = 1010
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "500, 4500"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
    security_rule {
    name                       = "Allow-Outbound-IPsec"
    priority                   = 1010
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "500, 4500"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
    security_rule {
    name                       = "Allow-HTTPS-In"
    priority                   = 1020
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
    security_rule {
    name                       = "Allow-HTTPS-Out"
    priority                   = 1020
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
    security_rule {
    name                       = "Default-Block-In"
    priority                   = 1030
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "0-65535"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
    security_rule {
    name                       = "Default-Block-Out"
    priority                   = 1030
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "0-65535"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}

resource "azurerm_virtual_network" "UAACSMainNet" {
  name     = "UAACSMainNet"
  location = "eastus"
  resource_group_name = "network-resources"
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "InternalNet"{
  name = "InternalNet"
  resource_group_name = "network-resources"
  virtual_network_name = "UAACSMainNet"
  address_prefixes = ["10.0.0.0/24"]
  default_outbound_access_enabled = false
}

resource "azurerm_subnet" "ExternalNet"{
  name = "ExternalNet"
  resource_group_name = "network-resources"
  virtual_network_name = "UAACSMainNet"
  address_prefixes = ["10.0.16.0/20"]
  private_endpoint_network_policies = "NetworkSecurityGroupEnabled"
  default_outbound_access_enabled = false
}

resource "azurerm_subnet_network_security_group_association" "InternalNSGtoSubnet" {
  subnet_id                 = azurerm_subnet.InternalNet.id
  network_security_group_id = azurerm_network_security_group.InternalNSG.id
}
resource "azurerm_subnet_network_security_group_association" "ExternalNSGtoSubnet" {
  subnet_id                 = azurerm_subnet.ExternalNet.id
  network_security_group_id = azurerm_network_security_group.ExternalNSG.id
}

resource "azurerm_nat_gateway" "NATtoInternet" {
  name     = "NATtoInternet"
  location = "eastus"
  resource_group_name = "network-resources"
}

resource "azurerm_subnet_nat_gateway_association" "NATtoExternalSubnet" {
  subnet_id      = azurerm_subnet.ExternalNet.id
  nat_gateway_id = azurerm_nat_gateway.NATtoInternet.id
}

resource "azurerm_network_interface" "WInt1" {
  name                = "WInternalInt1"
  location            = "eastus"
  resource_group_name = "network-resources"
  accelerated_networking_enabled = true

  ip_configuration {
    name                          = "internalIPconfig1"
    subnet_id                     = azurerm_subnet.InternalNet.id
    private_ip_address_allocation = "Dynamic"
  }
}
resource "azurerm_network_interface" "WInt2" {
  name                = "WInternalInt2"
  location            = "eastus"
  resource_group_name = "network-resources"
  accelerated_networking_enabled = true

  ip_configuration {
    name                          = "internalIPconfig2"
    subnet_id                     = azurerm_subnet.InternalNet.id
    private_ip_address_allocation = "Dynamic"
  }
}
resource "azurerm_network_interface" "WInt3" {
  name                = "WInternalInt3"
  location            = "eastus"
  resource_group_name = "network-resources"
  accelerated_networking_enabled = true

  ip_configuration {
    name                          = "internalIPconfig3"
    subnet_id                     = azurerm_subnet.InternalNet.id
    private_ip_address_allocation = "Dynamic"
  }
}
resource "azurerm_network_interface" "WInt4" {
  name                = "WInternalInt4"
  location            = "eastus"
  resource_group_name = "network-resources"
  accelerated_networking_enabled = true

  ip_configuration {
    name                          = "internalIPconfig4"
    subnet_id                     = azurerm_subnet.InternalNet.id
    private_ip_address_allocation = "Dynamic"
  }
}
resource "azurerm_network_interface" "LInt1" {
  name                = "LInternalInt1"
  location            = "eastus"
  resource_group_name = "network-resources"
  accelerated_networking_enabled = true

  ip_configuration {
    name                          = "internalIPconfig5"
    subnet_id                     = azurerm_subnet.InternalNet.id
    private_ip_address_allocation = "Dynamic"
  }
}
resource "azurerm_network_interface" "LInt2" {
  name                = "LInternalInt1"
  location            = "eastus"
  resource_group_name = "network-resources"
  accelerated_networking_enabled = true

  ip_configuration {
    name                          = "internalIPconfig6"
    subnet_id                     = azurerm_subnet.InternalNet.id
    private_ip_address_allocation = "Dynamic"
  }
}
resource "azurerm_network_interface" "LInt3" {
  name                = "LExternalInt1"
  location            = "eastus"
  resource_group_name = "network-resources"
  accelerated_networking_enabled = true

  ip_configuration {
    name                          = "externalIPconfig1"
    subnet_id                     = azurerm_subnet.ExternalNet.id
    private_ip_address_allocation = "Dynamic"
  }
}
resource "azurerm_network_interface" "LInt4" {
  name                = "LExternalInt2"
  location            = "eastus"
  resource_group_name = "network-resources"
  accelerated_networking_enabled = true

  ip_configuration {
    name                          = "externalIPconfig2"
    subnet_id                     = azurerm_subnet.ExternalNet.id
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
    azurerm_network_interface.WInt1.id
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
    azurerm_network_interface.WInt2.id
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
    azurerm_network_interface.WInt3.id
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
    azurerm_network_interface.WInt4.id
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
    azurerm_network_interface.LInt1.id
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
    azurerm_network_interface.LInt2.id
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
    azurerm_network_interface.LInt3.id
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
    azurerm_network_interface.LInt4.id
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
