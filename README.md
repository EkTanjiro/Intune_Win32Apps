### **Synopsis:**

This PowerShell script automates the process of installing MATLAB on a Windows machine using either a `.zip` or `.iso` file. It does the following:

1. **Scans for `.zip` or `.iso` file**: It searches the script directory for the installation file (`.zip` or `.iso`).
2. **Extracts `.zip` or mounts `.iso`**: If a `.zip` file is found, it will extract the contents to `C:\Temp\$MATLABVersion`. If an `.iso` file is found, it will mount the ISO.
3. **Creates an installation input file**: A version-specific `install_input.txt` file is created with the necessary installation parameters, such as the license key and configuration options. The input file is placed in the installation directory.
4. **Runs the MATLAB Installer**: The MATLAB installer is launched using the `setup.exe` with the input file.
5. **Creates the network.lic file**: A `network.lic` file with the appropriate network license server information is created in the MATLAB installation directory.
6. **Logs the Installation Process**: The installation process is logged to `C:\Temp\MatlabInstall_$MATLABVersion.log`.

### **How to Create the `.intunewin` File for Microsoft Intune Deployment**:

Once the script successfully installs MATLAB, you can use the **Microsoft-Win32-Content-Prep-Tool** to package the installer into a `.intunewin` file for deployment through **Microsoft Intune**. Here’s how to create the `.intunewin` file:

1. **Download and Install the Microsoft-Win32-Content-Prep-Tool**:
   - Download the tool from the [Microsoft Intune documentation](https://docs.microsoft.com/en-us/mem/intune/apps/apps-win32-app-management).
   - Extract the content of the tool to a directory of your choice.

2. **Prepare Your MATLAB Installation Files**:
   - Ensure that the script has successfully installed MATLAB on the target machine.
   - If you have used the script, you will already have the installation files (e.g., extracted `.zip` or mounted `.iso` files) located in `C:\Temp\$MATLABVersion`.

3. **Create the `.intunewin` File**:
   - Open a Command Prompt window and navigate to the directory where you extracted the **Microsoft-Win32-Content-Prep-Tool**.
   - Run the following command to package the PowerShell installation script into the `.intunewin` format:

     ```powershell
     .\IntuneWinAppUtil -c "C:\prep\$MATLABVersion" -s "C:\prep\$MATLABVersion\matlab_install.ps1" -o "C:\prep\$MATLABVersion" -q
     ```

     Explanation of the parameters:
     - `-c` specifies the content folder (in this case, the MATLAB installation directory `C:\Temp\$MATLABVersion`).
     - `-s` specifies the path to the PowerShell script (`matlab_install.ps1`) that handles the installation process.
     - `-o` specifies the output directory where the `.intunewin` file will be generated (`C:\Temp`).
     - `-q` runs the tool in quiet mode.

4. **Verify the Output**:
   - After running the command, a `.intunewin` file will be created in the specified output directory (`C:\Temp`). This file can now be uploaded to **Microsoft Intune** for deployment.

### **How to Deploy the `.intunewin` File via Microsoft Intune**:

1. **Upload the `.intunewin` File to Intune**:
   - Go to the **Microsoft Endpoint Manager admin center**.
   - Navigate to **Apps** > **Windows** > **Add** > **Win32 app**.
   - Select the `.intunewin` file you created earlier and follow the steps to configure deployment options.

2. **Assign the Application**:
   - Assign the application to the desired devices or groups within Intune.

3. **Monitor the Installation**:
   - After deployment, you can monitor the installation progress via the **Intune admin center**.

