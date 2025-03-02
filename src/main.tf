# Resource Group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

# Azure Compute Gallery
resource "azurerm_shared_image_gallery" "main" {
  name                = var.gallery_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  description         = "Azure Compute Gallery for sharing VM images."
}

# Image Definition
resource "azurerm_shared_image" "main" {
  name                = var.image_definition_name
  gallery_name        = azurerm_shared_image_gallery.main.name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  os_type             = var.os_type

  hyper_v_generation = "V2"

  identifier {
    publisher = var.publisher
    offer     = var.offer
    sku       = var.sku
  }
}
