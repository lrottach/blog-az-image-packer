# Install-Winget.ps1
# Script to download and install Winget CLI and its dependencies

# Function to write log messages
function Write-Log {
    param (
        [string]$Message,
        [string]$LogLevel = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "$timestamp [$LogLevel] $Message"
    Write-Host $logMessage
    Add-Content -Path "$PSScriptRoot\winget_install.log" -Value $logMessage
}

# Function to download a file
function Download-File {
    param (
        [string]$Url,
        [string]$OutputPath
    )
    try {
        Write-Log "Downloading $Url to $OutputPath"
        Invoke-WebRequest -Uri $Url -OutFile $OutputPath -UseBasicParsing
        Write-Log "Download completed successfully"
    }
    catch {
        Write-Log "Failed to download $Url. Error: $_" -LogLevel "ERROR"
        throw
    }
}

# Main script execution
try {
    # Ensure we're running with administrator privileges
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Log "This script requires administrator privileges. Please run as administrator." -LogLevel "ERROR"
        exit 1
    }

    # Set TLS to 1.2
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    # Create temporary directory
    $tempDir = Join-Path $env:TEMP "WingetInstall"
    New-Item -ItemType Directory -Force -Path $tempDir | Out-Null

    # Download Winget
    $wingetUrl = "https://api.github.com/repos/microsoft/winget-cli/releases/latest"
    $latestRelease = Invoke-RestMethod -Uri $wingetUrl -UseBasicParsing
    $assetUrl = ($latestRelease.assets | Where-Object { $_.name -match '^Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle$' }).browser_download_url
    $wingetPath = Join-Path $tempDir "Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
    Download-File -Url $assetUrl -OutputPath $wingetPath

    # Download VCLibs
    $vcLibsUrl = "https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx"
    $vcLibsPath = Join-Path $tempDir "Microsoft.VCLibs.x64.14.00.Desktop.appx"
    Download-File -Url $vcLibsUrl -OutputPath $vcLibsPath

    # Download and extract UI.Xaml (version 2.8.6)
    $uiXamlUrl = "https://www.nuget.org/api/v2/package/Microsoft.UI.Xaml/2.8.6"
    $uiXamlZipPath = Join-Path $tempDir "Microsoft.UI.Xaml.2.8.6.zip"
    Download-File -Url $uiXamlUrl -OutputPath $uiXamlZipPath

    $uiXamlExtractPath = Join-Path $tempDir "Microsoft.UI.Xaml.2.8.6"
    Expand-Archive -Path $uiXamlZipPath -DestinationPath $uiXamlExtractPath -Force
    $uiXamlAppxPath = Join-Path $uiXamlExtractPath "tools\AppX\x64\Release\Microsoft.UI.Xaml.2.8.appx"

    # Install Winget and dependencies
    Write-Log "Installing Winget and dependencies"
    try {
        Add-AppxPackage -Path $wingetPath -DependencyPath $vcLibsPath, $uiXamlAppxPath
        Write-Log "Winget installed successfully"
    }
    catch {
        Write-Log "Failed to install Winget. Error: $_" -LogLevel "ERROR"
        throw
    }

    # Verify installation
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Log "Winget is now available. Version: $(winget --version)"
    }
    else {
        Write-Log "Winget installation completed, but the 'winget' command is not available. You may need to restart your system." -LogLevel "WARN"
    }

    # Clean up
    Remove-Item -Path $tempDir -Recurse -Force
    Write-Log "Temporary files cleaned up"
    exit 0
}
catch {
    Write-Log "An error occurred during the installation process: $_" -LogLevel "ERROR"
    exit 1
}
