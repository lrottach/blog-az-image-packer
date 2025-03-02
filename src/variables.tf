variable "resource_group_name" {
  description = "The name of the Azure Resource Group."
  type        = string
}

variable "location" {
  description = "The Azure region for the resources."
  type        = string
  default     = "East US"
}

variable "gallery_name" {
  description = "The name of the Azure Compute Gallery."
  type        = string
}

variable "image_definition_name" {
  description = "The name of the image definition in the Azure Compute Gallery."
  type        = string
}

variable "publisher" {
  description = "The publisher of the image."
  type        = string
  default     = "Canonical"
}

variable "offer" {
  description = "The offer of the image."
  type        = string
  default     = "UbuntuServer"
}

variable "sku" {
  description = "The SKU of the image."
  type        = string
  default     = "18.04-LTS"
}

variable "os_type" {
  description = "The OS type of the image (Linux or Windows)."
  type        = string
  default     = "Linux"
}
