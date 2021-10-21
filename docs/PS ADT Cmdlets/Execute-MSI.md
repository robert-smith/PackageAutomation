Execute-MSI
===========

SYNOPSIS
--------

Executes msiexec.exe to perform the following actions for MSI & MSP
files and MSI product codes: install, uninstall, patch, repair, active
setup.

SYNTAX
------

```powershell
Execute-MSI [[-Action] <String>] [-Path] <String> [[-Transform] <String>] [[-Parameters] <String>] [[-AddParameters] <String>] [-SecureParameters] [[-Patch] <String>] [[-LoggingOptions] <String>] [[-private:LogName] <String>] [[-WorkingDirectory] <String>] [-SkipMSIAlreadyInstalledCheck] [-IncludeUpdatesAndHotfixes] [-PassThru] [[-ContinueOnError] <Boolean>] [<CommonParameters>]
```

DESCRIPTION
-----------

Executes msiexec.exe to perform the following actions for MSI & MSP
files and MSI product codes: install, uninstall, patch, repair, active
setup.

If the -Action parameter is set to "Install" and the MSI is already
installed, the function will exit.

Sets default switches to be passed to msiexec based on the preferences
in the XML configuration file.

Automatically generates a log file name and creates a verbose log file
for all msiexec operations.

Expects the MSI or MSP file to be located in the "Files" sub directory
of the App Deploy Toolkit. Expects transform files to be in the same
directory as the MSI file.

PARAMETERS
----------

### -Action

**Type**: `<String>`

The action to perform. Options: Install, Uninstall, Patch, Repair,
ActiveSetup.

### -Path

**Type**: `<String>`

The path to the MSI/MSP file or the product code of the installed MSI.

### -Transform

**Type**: `<String>`

The name of the transform file(s) to be applied to the MSI. The
transform file is expected to be in the same directory as the MSI file.

### -Parameters

**Type**: `<String>`

Overrides the default parameters specified in the XML configuration
file. Install default is: "REBOOT=ReallySuppress /QB!". Uninstall
default is: "REBOOT=ReallySuppress /QN".

### -AddParameters

**Type**: `<String>`

Adds to the default parameters specified in the XML configuration file.
Install default is: "REBOOT=ReallySuppress /QB!". Uninstall default is:
"REBOOT=ReallySuppress /QN".

### -SecureParameters

**Type**: `[<SwitchParameter>]`

Hides all parameters passed to the MSI or MSP file from the toolkit Log
file.

### -Patch

**Type**: `<String>`

The name of the patch (msp) file(s) to be applied to the MSI for use
with the "Install" action. The patch file is expected to be in the same
directory as the MSI file.

### -LoggingOptions

**Type**: `<String>`

Overrides the default logging options specified in the XML configuration
file. Default options are: "/L*v".

-private:LogName <String>

### -WorkingDirectory

**Type**: `<String>`

Overrides the working directory. The working directory is set to the
location of the MSI file.

### -SkipMSIAlreadyInstalledCheck

**Type**: `[<SwitchParameter>]`

Skips the check to determine if the MSI is already installed on the
system. Default is: $false.

### -IncludeUpdatesAndHotfixes

**Type**: `[<SwitchParameter>]`

Include matches against updates and hotfixes in results.

### -PassThru

**Type**: `[<SwitchParameter>]`

Returns ExitCode, STDOut, and STDErr output from the process.

### -ContinueOnError

**Type**: `<Boolean>`

Continue if an exit code is returned by msiexec that is not recognized
by the App Deploy Toolkit. Default is: $false.

-------------------------- EXAMPLE 1 --------------------------

```powershell
PS C:\>Execute-MSI -Action 'Install' -Path 'Adobe_FlashPlayer_11.2.202.233_x64_EN.msi'
```

Installs an MSI

-------------------------- EXAMPLE 2 --------------------------

```powershell
PS C:\>Execute-MSI -Action 'Install' -Path 'Adobe_FlashPlayer_11.2.202.233_x64_EN.msi' -Transform 'Adobe_FlashPlayer_11.2.202.233_x64_EN_01.mst' -Parameters '/QN'
```

Installs an MSI, applying a transform and overriding the default MSI
toolkit parameters

-------------------------- EXAMPLE 3 --------------------------

```powershell
PS C:\>[psobject]$ExecuteMSIResult = Execute-MSI -Action 'Install' -Path 'Adobe_FlashPlayer_11.2.202.233_x64_EN.msi' -PassThru
```

Installs an MSI and stores the result of the execution into a variable
by using the -PassThru option

-------------------------- EXAMPLE 4 --------------------------

```powershell
PS C:\>Execute-MSI -Action 'Uninstall' -Path '{26923b43-4d38-484f-9b9e-de460746276c}'
```

Uninstalls an MSI using a product code

-------------------------- EXAMPLE 5 --------------------------

```powershell
PS C:\>Execute-MSI -Action 'Patch' -Path 'Adobe_Reader_11.0.3_EN.msp'
```

Installs an MSP
