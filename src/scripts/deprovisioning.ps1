# Define an array of known problematic appx packages
$packagesToRemove = @(
    "Microsoft.Winget.Source*",
    "Microsoft.Ink.Handwriting*"
)

# Remove known problematic appx packages
Write-Output "Removing known problematic appx packages..."
foreach ($package in $packagesToRemove) {
    try {
        Get-AppxPackage | Where-Object Name -Like $package | Remove-AppxPackage
        Write-Output "Successfully removed package: $package"
    }
    catch {
        Write-Output "Failed to remove package: $package. Error: $_"
    }
}

# Ensure Guest Agent services are running
$guestAgentServices = @("RdAgent", "WindowsAzureTelemetryService", "WindowsAzureGuestAgent")
foreach ($service in $guestAgentServices) {
    $svc = Get-Service -Name $service -ErrorAction SilentlyContinue
    if ($svc) {
        while ((Get-Service $service).Status -ne 'Running') {
            Write-Output "Waiting for $service to start..."
            Start-Sleep -Seconds 5
        }
        Write-Output "$service is now running."
    }
    else {
        Write-Output "$service not found, skipping."
    }
}

# Run Sysprep
Write-Output "Starting Sysprep process..."
$sysprepPath = "$env:SystemRoot\System32\Sysprep\Sysprep.exe"
$sysprepArgs = "/oobe /generalize /quiet /quit /mode:vm"
Start-Process -FilePath $sysprepPath -ArgumentList $sysprepArgs

# Wait for Sysprep to complete
Write-Output "Waiting for Sysprep to complete..."
while($true) {
    $imageState = Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Setup\State | Select-Object -ExpandProperty ImageState
    if($imageState -ne 'IMAGE_STATE_GENERALIZE_RESEAL_TO_OOBE') {
        Write-Output "Current state: $imageState"
        Start-Sleep -Seconds 10
    } else {
        Write-Output "Sysprep completed successfully."
        Start-Sleep -Seconds 30
        break
    }
}

Write-Output "Deprovisioning process completed."
