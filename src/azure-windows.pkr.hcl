packer {
  required_plugins {
    azure = {
      source  = "github.com/hashicorp/azure"
      version = "~> 2"
    }
  }
}


source "azure-arm" "windows11" {
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  subscription_id = "${var.subscription_id}"
  tenant_id       = "${var.tenant_id}"

  os_type         = "Windows"
  image_offer     = "windows-11"
  image_publisher = "microsoftwindowsdesktop"
  image_sku       = "win11-22h2-pro"

  vm_size                           = "Standard_B4as_v2"
  managed_image_resource_group_name = "your-resource-group-name"
  managed_image_name                = "windows11-custom-image-v5"

  location = "East US"

  communicator   = "winrm"
  winrm_use_ssl  = true
  winrm_insecure = true
  winrm_timeout  = "5m"
  winrm_username = "packer"
}

build {
  sources = ["source.azure-arm.windows11"]

  provisioner "powershell" {
    script = "./scripts/install-pwsh.ps1"
  }

  provisioner "windows-restart" {
    restart_check_command = "powershell -command \"& {Write-Output 'restarted.'}\""
  }

  provisioner "powershell" {
    use_pwsh = true
    inline   = ["winget source update"]
  }

  //   provisioner "powershell" {
  //     inline = [
  //         "(Get-AppxPackage Microsoft.DesktopAppInstaller).Version",

  //       # Update winget source
  //       "winget source update",

  //       # Install Visual Studio Code
  //       "winget install -e --id Microsoft.VisualStudioCode --accept-source-agreements --accept-package-agreements",

  //       # Install PowerShell 7
  //       "winget install -e --id Microsoft.PowerShell --accept-source-agreements --accept-package-agreements",

  //       # Install Visual Studio (Community edition)
  //       "winget install -e --id Microsoft.VisualStudio.2022.Community --accept-source-agreements --accept-package-agreements",

  //       # Optional: Wait for installations to complete
  //       "Start-Sleep -Seconds 30",

  //       # Optional: Verify installations
  //       "Write-Host 'Installed Software:'",
  //       "winget list"
  //     ]
  //   }
}

variable "client_id" {
  type    = string
  default = "${env("PKR_VAR_client_id")}"
}

variable "client_secret" {
  type    = string
  default = "${env("PKR_VAR_client_secret")}"
}

variable "subscription_id" {
  type    = string
  default = "${env("PKR_VAR_subscription_id")}"
}

variable "tenant_id" {
  type    = string
  default = "${env("PKR_VAR_tenant_id")}"
}
