resource "azurerm_virtual_network" "east_net" {
  name                = "Eastern-network"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.name
}

resource "azurerm_subnet" "sub_east" {
  name                 = "internal"
  resource_group_name  = var.name
  virtual_network_name = azurerm_virtual_network.east_net.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "nic_name" {
  name                = "dexter-nic"
  location            =  var.location
  resource_group_name =  var.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.sub_east.id
    private_ip_address_allocation = "Dynamic"
	public_ip_address_id = azurerm_public_ip.dexter.id
	
  }
}

resource "azurerm_windows_virtual_machine" "Dexter-vm" {
  name                = "Dexter-lab"
  resource_group_name = var.name
  location            = var.location
  size                = "Standard_DS1"
  admin_username      = var.username
  admin_password      = var.vm_password
  network_interface_ids = [
    azurerm_network_interface.nic_name.id,
  ]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2008-R2-SP1"
    version   = "latest"
  }
}
resource "azurerm_public_ip" "dexter"{
  name                = "publicip1"
  resource_group_name = var.name
  location            =  var.location
  allocation_method   = "Static"
}
