output "resource_group_id" {
  description = "The ID of the Resource Group."
  value       = azurerm_resource_group.main.id
}

output "resource_group_name" {
  description = "The name of the Resource Group."
  value       = azurerm_resource_group.main.name
}

output "gallery_id" {
  description = "The ID of the Azure Compute Gallery."
  value       = azurerm_shared_image_gallery.main.id
}

output "gallery_name" {
  description = "The name of the Azure Compute Gallery."
  value       = azurerm_shared_image_gallery.main.name
}

output "image_definition_id" {
  description = "The ID of the image definition."
  value       = azurerm_shared_image.main.id
}

output "image_definition_name" {
  description = "The name of the image definition."
  value       = azurerm_shared_image.main.name

}
