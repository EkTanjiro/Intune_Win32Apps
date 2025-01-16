# ============================================================================ 
# MATLAB Installation Script 
#
# SYNOPSIS:
# This script automates the process of installing MATLAB on Windows. It scans the directory
# where the script is located for either a ZIP or ISO installation file, extracts or mounts it,
# and runs the MATLAB setup with a pre-defined configuration.
#
# It also:
# 1. Creates a specific install input file (e.g., R2024b_install_input.txt).
# 2. Installs MATLAB using that input file.
# 3. Creates a network license file (network.lic) in the MATLAB installation folder.
#
# GUIDE FOR UPDATING VERSION AND INSTALLATION KEY:
# - To update the MATLAB version, change the value of the `$MATLABVersion` variable.
#   Example: For MATLAB R2024b, change `$MATLABVersion = "R2024b"` to `$MATLABVersion = "R2025a"`.
#
# - To update the installation key, change the value of the `$fileInstallationKey` variable.
#   Example: For a new installation key, update `$fileInstallationKey` with the new key provided by MathWorks.
#
# ============================================================================

# Centralized variables
$MATLABVersion = "R2024b"  # Update the version here for different installs (e.g., "R2025b")
$fileInstallationKey = "09751-54713-34396-42753-51056-10851-42435-07094-05946-14469-06793 example key" # Update `$fileInstallationKey` with the new key provided by MathWorks.
$scriptDirectory = $PSScriptRoot # Directory where the script is located

# Ensure Temp directory exists
$tempDirectory = "C:\Temp"
if (-not (Test-Path $tempDirectory)) {
    New-Item -Path $tempDirectory -ItemType Directory -Force
}

$logFile = "$tempDirectory\MatlabInstall_$MATLABVersion.log"
$inputFile = "$MATLABVersion_install_input.txt"
$licenseServer = "changeme.edu" # Update to Matlab license server FQDN 
$licenseIP = "192.168.200.200" # Update to Matlab license server IP address
$licensePort = "1701"
$extractPath = "$tempDirectory\$MATLABVersion"  # Extract to C:\Temp\$MATLABVersion
$installDir = "C:\Program Files\MATLAB\$MATLABVersion"  # Correct MATLAB install directory for Windows

# Log function
function Log-Message {
    param (
        [string]$message,
        [string]$level = "INFO"
    )
    
    $currentDate = Get-Date -Format "MM/dd/yyyy hh:mm tt"
    $logEntry = "$currentDate [$level] $message"
    
    # Append the log entry to the log file
    Add-Content -Path $logFile -Value $logEntry
}

# Initialize log file
if (Test-Path $logFile) {
    Log-Message "Appending log to existing file"
} else {
    New-Item -Path $logFile -ItemType File
    Log-Message "Creating a new log file"
}

# Step 1: Scan for either ZIP or ISO file in the script's directory
$installFile = Get-ChildItem -Path $scriptDirectory -File | Where-Object { $_.Extension -eq ".zip" -or $_.Extension -eq ".iso" } | Select-Object -First 1

if ($installFile) {
    $installFileName = $installFile.Name
    Log-Message "Found installation file: $installFileName"
} else {
    Log-Message "No ZIP or ISO file found in the script directory. Installation aborted." "ERROR"
    exit 1
}

# Step 2: If ZIP file, extract it; if ISO file, mount it
if ($installFile.Extension -eq ".zip") {
    # Extract ZIP file
    try {
        Log-Message "Extracting ZIP file $installFileName to $extractPath"
        Expand-Archive -Path "$scriptDirectory\$installFileName" -DestinationPath $extractPath -Force
        Log-Message "ZIP file extracted to $extractPath"
    } catch {
        Log-Message "Error extracting ZIP file: $($_.Exception.Message)" "ERROR"
        exit 1
    }
} elseif ($installFile.Extension -eq ".iso") {
    # Mount ISO file
    try {
        $mountedDrive = Mount-DiskImage -ImagePath "$scriptDirectory\$installFileName" -PassThru | Get-Volume | Select-Object -First 1
        $isoDriveLetter = $mountedDrive.DriveLetter
        $isoPath = "$isoDriveLetter`:\"  # Mount location of the ISO
        Log-Message "Mounted ISO file at $isoPath"
    } catch {
        Log-Message "Error mounting ISO file: $($_.Exception.Message)" "ERROR"
        exit 1
    }
}

# Step 3: Create the install_input.txt for the specific MATLAB version (R2024b_install_input.txt)
try {
    # Define the path for the input file
    $installInputPath = "$extractPath\$MATLABVersion`_install_input.txt"

    # Ensure the directory exists
    if (-not (Test-Path -Path $extractPath)) {
        New-Item -Path $extractPath -ItemType Directory -Force | Out-Null
        Log-Message "Created directory $extractPath"
    }

    # Define the content of the install input file
    $installInputContent = @"
fileInstallationKey=$fileInstallationKey
destinationFolder=$installDir
agreeToLicense=yes
setFileAssoc=true
desktopShortcut=true
startMenuShortcut=true
createAccelTask=false
enableLNU=no
improveMATLAB=no
"@
    
    # Create the install input file
    Set-Content -Path $installInputPath -Value $installInputContent
    Log-Message "Created install input file $installInputPath"
} catch {
    Log-Message "Error creating install input file: $($_.Exception.Message)" "ERROR"
    exit 1
}

# Step 4: Run the MATLAB installer (from extracted or mounted ISO path)
$setupFilePath = if ($installFile.Extension -eq ".zip") { "$extractPath\setup.exe" } else { "$isoPath\setup.exe" }

if (Test-Path $setupFilePath) {
    try {
        # Add -mode silent to suppress any pop-ups or interaction
        $argumentList = "-inputFile $installInputPath -mode silent"
        Log-Message "Running MATLAB installer from $setupFilePath with input file $installInputPath"
        
        # Start the installation process and wait for it to finish
        $process = Start-Process -FilePath $setupFilePath -ArgumentList $argumentList -PassThru -Wait -ErrorAction Stop
        
        # Log the exit code to ensure completion
        if ($process.ExitCode -eq 0) {
            Log-Message "MATLAB installation completed successfully."
        } else {
            Log-Message "MATLAB installation failed with exit code $($process.ExitCode)." "ERROR"
            exit 1
        }
    } catch {
        Log-Message ("Error executing {0}: {1}" -f $setupFilePath, $_.Exception.Message) "ERROR"
        exit 1
    }
} else {
    Log-Message "$setupFilePath not found. Installation aborted." "ERROR"
    exit 1
}


# Step 5: Create the network.lic file in the MATLAB install folder
try {
    $networkLicContent = @"
SERVER $licenseServer INTERNET=$licenseIP $licensePort
USE_SERVER
"@
    # Ensure the installation directory exists, then create the network.lic file
    $licFolderPath = "$installDir\licenses"
    New-Item -Path $licFolderPath -ItemType Directory -Force | Out-Null
    Set-Content -Path "$licFolderPath\network.lic" -Value $networkLicContent
    Log-Message "Created network.lic file at $licFolderPath\network.lic"
} catch {
    Log-Message "Error creating network.lic file: $($_.Exception.Message)" "ERROR"
    exit 1
}

# Step 6: Log completion message
Log-Message "Installation of MATLAB $MATLABVersion completed" "INFO"
