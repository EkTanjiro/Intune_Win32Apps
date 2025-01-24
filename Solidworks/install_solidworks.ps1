<#
.SYNOPSIS
    Script to install or uninstall the SOLIDWORKS Administrative Image on client machines.

.DESCRIPTION
    This script installs or uninstalls SOLIDWORKS using the specified options. 
    It can be used for deploying or removing SOLIDWORKS through Intune or similar deployment tools.

    Available Options:
    - /install         Installs the administrative image on client machines.
    - /uninstall       Uninstalls the software from client machines.
                       Optional switches for uninstall:
                       - /removedata    Removes SOLIDWORKS data files and folders during uninstall.
                       - /removeregistry Removes SOLIDWORKS registry entries during uninstall.
    - /showui          Displays a progress window for the SOLIDWORKS Installation Manager (hidden by default).
    - /now             Starts the install or uninstall immediately without a 5-minute warning dialog.

.NOTES
    Author: Ek Tanjiro
    Date: 2025/01/24
    Version: 1.0
    Ensure that the network path to the SOLIDWORKS installer is accessible.
#>

# PowerShell Script to Install SOLIDWORKS Administrative Image
Write-Host "Installing SOLIDWORKS Administrative Image..."

# Define the path to the installation executable
$installerPath = "\\Shared_drive\swadmin\StartSWInstall.exe"

# Installation arguments
$arguments = "/install /now /showui"

# Start the installation
try {
    Start-Process -FilePath $installerPath -ArgumentList $arguments -Wait -NoNewWindow
    Write-Host "SOLIDWORKS installation started successfully."
} catch {
    Write-Error "An error occurred while starting the SOLIDWORKS installation: $_"
}

# Exit the script
exit
