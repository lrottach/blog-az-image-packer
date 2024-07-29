// ***********************************************************************
//
//  Author: Lukas Rottach
//  GitHub: https://github.com/lrottach
//  Description: Windows 11 Enterprise - Packer demo
//
// ***********************************************************************

// Variables
// **********************

variable "client_id" {
  type    = string
  default = "${env("ENV_PACKER_APP_ID")}"
}

variable "client_secret" {
  type    = string
  default = "${env("ENV_PACKER_APP_SECRET")}"
}

variable "subscription_id" {
  type    = string
  default = "${env("ENV_PACKER_SUBSCRIPTION_ID")}"
}

variable "tenant_id" {
  type    = string
  default = "${env("ENV_PACKER_TENANT_ID")}"
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

source "azure-arm" "windows-11-ent" {

  // Authentication
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  subscription_id = "${var.subscription_id}"
  tenant_id       = "${var.tenant_id}"

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

  // Managed Image information
  managed_image_resource_group_name = "your-resource-group-name"
  managed_image_name                = "windows11-ent-packer-image-v4-eus"
}

// Build
// **********************

build {
  sources = ["source.azure-arm.windows11"]

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
