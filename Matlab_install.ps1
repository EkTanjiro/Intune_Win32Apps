# Synopsis:
# This PowerShell script automates the installation process of MATLAB R2023a.
# It extracts the contents of a zip file, runs the setup.exe file with an input file,
# copies the license file to the installation directory, and cleans up the extraction directory.
# installer_input & network.lic should be in the same folder as setup.exe

$packageName = "Matlab R2023a"
$setupFile = "setup.exe"
$inputFile = "installer_input.txt"
$zipFile = "r2023a.zip"
$extractPath = "C:\Temp\r2023a"
$logFile = "C:\Temp\MatlabInstall.log"
$licFile = "network.lic"
$installDir = "C:\Program Files\MATLAB\R2023a"

# Create a log file
Start-Transcript -Path $logFile

# Extract the contents of the zip file to the destination directory
Expand-Archive -Path "$PSScriptRoot\$zipFile" -DestinationPath $extractPath

# Run the setup.exe file with the input file "installer_input.txt"
Start-Process -FilePath "$extractPath\$setupFile" -ArgumentList "-inputFile $extractPath\$inputFile" -Wait

# Create the licenses folder in the Matlab installation directory
New-Item -Path "$installDir\licenses" -ItemType Directory -Force

# Copy the license file to the Matlab licenses directory
Copy-Item -Path "$extractPath\$licFile" -Destination "$installDir\licenses" -Force

# Delete the extraction directory
Remove-Item -Path $extractPath -Recurse -Force

# Stop logging
Stop-Transcript
