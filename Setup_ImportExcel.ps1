# Define the module name
$moduleName = "ImportExcel"

# Define the user module path
$modulePath = "$HOME\Documents\PowerShell\Modules\$moduleName"

# Check if the module is already installed
if (-not (Get-Module -ListAvailable -Name $moduleName)) {
    Write-Host "Module $moduleName not found. Installing locally..." -ForegroundColor Yellow

    # Ensure the Modules directory exists
    if (!(Test-Path "$HOME\Documents\PowerShell\Modules")) {
        New-Item -Path "$HOME\Documents\PowerShell\Modules" -ItemType Directory -Force
    }

    # Try installing via Install-Module
    try {
        Install-Module -Name $moduleName -Scope CurrentUser -Force -ErrorAction Stop
    } catch {
        Write-Host "Install-Module failed. Attempting manual download..." -ForegroundColor Red
        
        # Manual download method
        $packageUrl = "https://www.powershellgallery.com/api/v2/package/ImportExcel/latest"
        $zipPath = "$HOME\Downloads\$moduleName.zip"
        $extractPath = "$HOME\Downloads\$moduleName"

        # Download the module
        Invoke-WebRequest -Uri $packageUrl -OutFile $zipPath

        # Extract the module
        Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force

        # Move to PowerShell Modules directory
        Move-Item -Path "$extractPath\*" -Destination $modulePath -Force
    }
}

# Import the module
Import-Module "$extractPath"+"ImportExcel.psd1" -Force

# Verify installation
if (Get-Module -ListAvailable -Name $moduleName) {
    Write-Host "$moduleName module is successfully installed and loaded!" -ForegroundColor Green
} else {
    Write-Host "Failed to install or import $moduleName." -ForegroundColor Red
}

<#

A one-click PowerShell script that downloads, installs, and imports the ImportExcel module without admin privileges. Save this as Setup_ImportExcel.ps1 and run it in PowerShell.

How to Use:

1. Save the script as Setup_ImportExcel.ps1.


2. Run PowerShell (not as admin).


3. Navigate to the script location using:

cd "C:\path\to\script"


4. Run the script:

.\Setup_ImportExcel.ps1



This script automatically installs ImportExcel, imports it, and creates a test Excel file. Let me know if you need modifications!

#>
