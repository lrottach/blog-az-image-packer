// ***********************************************************************
//
//  Author: Lukas Rottach
//  GitHub: https://github.com/lrottach
//  Description: Windows 11 Enterprise - Packer demo
//
// ***********************************************************************

// Variables
// **********************

# variable "client_id" {
#   type    = string
#   default = "${env("ENV_PACKER_APP_ID")}"
# }

variable "subscription_id" {
  type    = string
  default = "${env("ARM_SUBSCRIPTION_ID")}"
}

# variable "arm_oidc_token" {
#   type    = string
#   default = "${env("ARM_OIDC_TOKEN")}"
# }

# variable "tenant_id" {
#   type    = string
#   default = "${env("ENV_PACKER_TENANT_ID")}"
# }

variable "image_gallery_name" {
  type    = string
  default = "acgdcod1img"
}

variable "image_gallery_resource_group" {
  type    = string
  default = "rg-dco-d1-img-gallery"
}

variable "image_definition_name" {
  type    = string
  default = "az-dev-w11-ent"
}

variable "image_version" {
  type    = string
  default = "1.0.0"
}

// Plugins
// **********************

packer {
  required_plugins {
    azure = {
      source  = "github.com/hashicorp/azure"
      version = "~> 2"
    }
  }
}

// Sources
// **********************

source "azure-arm" "win-11-ent" {

  // Authentication
  use_azure_cli_auth = true
#   use_oidc_credentials = true
#   client_id            = "${var.client_id}"
#   client_jwt           = "${var.arm_oidc_token}"
#   subscription_id      = "${var.subscription_id}"
  #   tenant_id       = "${var.tenant_id}"

  // Source image information
  os_type         = "Windows"
  image_offer     = "windows-11"
  image_publisher = "microsoftwindowsdesktop"
  image_sku       = "win11-23h2-ent"

  // Build VM size
  vm_size = "Standard_B8as_v2"

  // Location and public IP
  location      = "East US"
  public_ip_sku = "Standard"

  // Communicator (winrm) configuration
  communicator   = "winrm"
  winrm_use_ssl  = true
  winrm_insecure = true
  winrm_timeout  = "15m"
  winrm_username = "packer"

  // Shared Image Gallery configuration
  shared_image_gallery_destination {
    subscription         = "${var.subscription_id}"
    gallery_name         = "${var.image_gallery_name}"
    resource_group       = "${var.image_gallery_resource_group}"
    image_name           = "${var.image_definition_name}"
    image_version        = "${var.image_version}"
    storage_account_type = "Standard_LRS"
    target_region {
      name = "eastus"
    }
  }
  #   // Managed Image information
  #   managed_image_resource_group_name = "rg-p1-corp-packer-eus"
  #   managed_image_name                = "windows11-ent-packer-image-v1-eus"
}


// Build
// **********************

build {
  sources = ["source.azure-arm.win-11-ent"]

  provisioner "powershell" {
    inline = [
      # Installing chocolately package manager
      "Set-ExecutionPolicy Bypass -Scope Process -Force",
      "[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072",
      "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))"
    ]
  }

  provisioner "windows-restart" {
    restart_check_command = "powershell -command \"& {Write-Output 'restarted.'}\""
  }


  provisioner "powershell" {
    inline = [
      # Get chocolately version
      "choco --version",
      # Install - Azure CLI
      "choco install azure-cli --confirm --silent",

      # Install - Git
      "choco install git --confirm --silent",

      # Install - PowerShell
      "choco install powershell-core --confirm --silent"
    ]
  }

  provisioner "powershell" {
    script = "./scripts/deprovisioning.ps1"
  }
}
