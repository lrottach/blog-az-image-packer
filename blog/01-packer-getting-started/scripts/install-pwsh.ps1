# PowerShell script to download and install the latest PowerShell 7 MSI

Write-Host "[INFO] Starting PowerShell 7 download and installation process..."

# GitHub API URL for PowerShell releases
$apiUrl = "https://api.github.com/repos/PowerShell/PowerShell/releases/latest"

Write-Host "[INFO] Fetching latest release information from GitHub..."
try {
    # Get the latest release information
    $release = Invoke-RestMethod -Uri $apiUrl
    Write-Host "[SUCCESS] Successfully retrieved release information."
} catch {
    Write-Host "[ERROR] Failed to retrieve release information. Please check your internet connection."
    exit 1
}

Write-Host "[INFO] Locating MSI asset for 64-bit Windows..."
# Find the MSI asset for 64-bit Windows
$msiAsset = $release.assets | Where-Object { $_.name -like "*win-x64.msi" }

if (-not $msiAsset) {
    Write-Host "[ERROR] Could not find the MSI asset for 64-bit Windows."
    exit 1
}

# Download URL for the MSI
$downloadUrl = $msiAsset.browser_download_url
Write-Host "[INFO] Download URL: $downloadUrl"

# Local path to save the MSI
$msiPath = "$env:TEMP\PowerShell-7-x64.msi"

Write-Host "[INFO] Downloading PowerShell 7 MSI..."
try {
    # Download the MSI
    Invoke-WebRequest -Uri $downloadUrl -OutFile $msiPath
    Write-Host "[SUCCESS] Successfully downloaded PowerShell 7 MSI to $msiPath"
} catch {
    Write-Host "[ERROR] Failed to download the MSI file."
    exit 1
}

Write-Host "[INFO] Starting PowerShell 7 installation..."
try {
    # Install PowerShell 7
    $process = Start-Process -FilePath msiexec.exe -ArgumentList "/i `"$msiPath`" /qn" -Wait -PassThru
    if ($process.ExitCode -eq 0) {
        Write-Host "[SUCCESS] PowerShell 7 has been installed successfully."
    } else {
        Write-Host "[ERROR] Installation failed with exit code $($process.ExitCode)"
        exit 1
    }
} catch {
    Write-Host "[ERROR] An unexpected error occurred during installation."
    exit 1
}

Write-Host "[INFO] Cleaning up downloaded files..."
# Clean up the downloaded MSI
Remove-Item -Path $msiPath
Write-Host "[SUCCESS] Cleanup completed."

Write-Host "[SUCCESS] PowerShell 7 installation process completed."

exit 0
