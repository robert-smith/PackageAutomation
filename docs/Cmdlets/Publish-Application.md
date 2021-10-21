---
external help file: PackageAutomation-help.xml
Module Name: PackageAutomation
online version:
schema: 2.0.0
---

# Publish-Application

## SYNOPSIS
Define automatic package creation that detects new versions of an app and deploys them.

## SYNTAX

```
Publish-Application [[-Name] <String>] [[-ScriptBlock] <ScriptBlock>] [<CommonParameters>]
```

## DESCRIPTION
This command will perform the following actions:

**SCCM**

- Check for new app updates
- Compare what is already packaged
- Download the app if it is a newer version
- Copy the PowerShell App Deployment Toolkit files over to the target location
- Replace placeholders in the DeployApplication.ps1 file
- Create detection method rules
- Create a new SCCM application
- Distribute content
- Remove previous version deployments
- Deploy the new application
- Update the Install Application steps in specified task sequences
- Remove old versions of the application

**Intune**

- Package the application in intunewin format
- Create the application in Intune
- Remove all assignments from previous versions
- Assign the application to groups

See the `ScriptBlock` parameter documentation for details on what values are accepted.

## EXAMPLES

### Example 1
```powershell
Application 'VEXcode IQ Blocks' {
    URL = 'https://link.vex.com/vexcode-iq-blocks-msi'
    Destination = '\\contoso.com\apps\Packages\VEX\Code\IQ Blocks'

    InstallWelcomeParams = '-CloseApps "iqblocks=VEXcode IQ Blocks" -PersistPrompt -MinimizeWindows $false'
    UninstallWelcomeParams = '-CloseApps "iqblocks=VEXcode IQ Blocks" -CloseAppsCountdown 120 -PersistPrompt -MinimizeWindows $false'

    Install = {
        Execute-MSI -Action Install -Path $PSScriptRoot\Files\%%INSTALLERNAME%%
    }

    Uninstall = {
        Execute-MSI -Action Uninstall -Path '%%ProductCode%%'
    }

    SupersedeLastVersion = {
        Enabled = $true
        Uninstall = $false
    }

    DetectionRules = {

        RegistryValue {
            Hive = 'LocalMachine'
            KeyName = "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" + '%%ProductCode%%'
            ValueName = 'DisplayVersion'
            PropertyType = 'Version'
            ExpressionOperator = 'GreaterEquals'
            ExpectedValue = '%%Version%%'
        }
    }
}
```

This will create new versions of the VEXcode IQ Blocks app any time this is run. The URL specified is provided by the developer and always redirects to the latest version of the software.

### Example 2
```powershell
Application 'VEXcode IQ Blocks' {
    URL = 'https://link.vex.com/vexcode-iq-blocks-msi'
    Destination = '\\contoso.com\apps\Packages\VEX\Code\IQ Blocks'

    InstallWelcomeParams = '-CloseApps "iqblocks=VEXcode IQ Blocks" -PersistPrompt -MinimizeWindows $false'
    UninstallWelcomeParams = '-CloseApps "iqblocks=VEXcode IQ Blocks" -CloseAppsCountdown 120 -PersistPrompt -MinimizeWindows $false'

    Install = {
        Execute-MSI -Action Install -Path $PSScriptRoot\Files\%%INSTALLERNAME%%
    }

    Uninstall = {
        Execute-MSI -Action Uninstall -Path '%%ProductCode%%'
    }

    SupersedeLastVersion = {
        Enabled = $true
        Uninstall = $false
    }
    EstimatedRuntimeMins = 3
    MaximumRuntimeMins = 15

    DetectionRules = {

        RegistryValue {
            Hive = 'LocalMachine'
            KeyName = "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" + '%%ProductCode%%'
            ValueName = 'DisplayVersion'
            PropertyType = 'Version'
            ExpressionOperator = 'GreaterEquals'
            ExpectedValue = '%%Version%%'
        }
    }
}
```

This example shows how to specify an estimated install time of 3 minutes and make the installation timeout after 15 minutes.

### Example 3
```powershell
$BaseURL = 'https://download.testnav.com/'
$IE = New-Object -ComObject InternetExplorer.Application
$IE.navigate($BaseURL)
while ($IE.Busy) {
    Start-Sleep -Milliseconds 250
}
$Suffix = [regex]::Match($IE.Document.Body.innerHTML,'_testnavinstallers/.*?\.msi').Value
$DownloadURL = $BaseURL + $Suffix

Application TestNav {
    URL = $DownloadURL
    Destination = '\\contoso.com\apps\Packages\Pearson\TestNav'

    InstallWelcomeParams = '-CloseApps "testnav" -PersistPrompt -MinimizeWindows $false'
    UninstallWelcomeParams = '-CloseApps "testnav" -CloseAppsCountdown 120 -PersistPrompt -MinimizeWindows $false'

    Install = {
        Execute-MSI -Action Install -Path $PSScriptRoot\Files\%%INSTALLERNAME%%
    }

    Uninstall = {
        Execute-MSI -Action Uninstall -Path '%%ProductCode%%'
    }

    SupersedeLastVersion = {
        Enabled = $true
        Uninstall = $false
    }

    DetectionRules = {

        RegistryValue {
            Hive = 'LocalMachine'
            KeyName = "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" + '%%ProductCode%%'
            ValueName = 'DisplayVersion'
            PropertyType = 'Version'
            ExpressionOperator = 'GreaterEquals'
            ExpectedValue = '%%Version%%'
        }

        File {
            FileName = 'TestNav.exe'
            Path = "%ProgramFiles%\TestNav"
        }
    }
}
```

This is a more advanced example. The **TestNav** app does not have a URL that will automatically redirect to the latest version so it must be extracted off the download page. The code at the top will open an Internet Explorer instance, navigate to the **TestNav** download page, then extract the latest download URL. That will then be provided to the URL property for `Application`.

There is also a second detection method involved. This shows the use of both the registry and file detection methods. Any number of detection methods can be defined in the `DetectionRules` property.

### Example 4
```powershell
Application 'Adobe Reader DC' {
    URL = $DownloadURL
    Destination = '\\contoso.com\apps\Packages\Adobe\Reader\DC'

    InstallWelcomeParams = '-CloseApps "AcroRd32" -PersistPrompt -MinimizeWindows $false'
    UninstallWelcomeParams = '-CloseApps "AcroRd32" -CloseAppsCountdown 120 -PersistPrompt -MinimizeWindows $false'

    Install = {
        Execute-MSI -Action Install -Path $PSScriptRoot\Files\%%INSTALLERNAME%%
    }

    Uninstall = {
        Execute-MSI -Action Uninstall -Path '%%ProductCode%%'
    }

    RemovePreviousVersionDeployments = $true

    DetectionRules = {

        RegistryValue {
            Hive = 'LocalMachine'
            KeyName = "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" + '%%ProductCode%%'
            ValueName = 'DisplayVersion'
            PropertyType = 'Version'
            ExpressionOperator = 'GreaterEquals'
            ExpectedValue = '%%Version%%'
        }

        File {
            FileName = 'AcroRd32.exe'
            Path = "%ProgramFiles%\Adobe\Reader DC\Reader"
        }
    }

    TaskSequences = 'Post-WinPE', 'Post-WinPE-Senior'
    VersionsToKeep = 3
}
```

This shows an example of removing the previous version's deployments, updating multiple task sequences, and keeping only three versions of the application.

### Example 5
```powershell
Application 'Adobe Reader DC' {
    URL = $DownloadURL
    Destination = '\\contoso.com\apps\Packages\Adobe\Reader\DC'

    InstallWelcomeParams = '-CloseApps "AcroRd32" -PersistPrompt -MinimizeWindows $false'
    UninstallWelcomeParams = '-CloseApps "AcroRd32" -CloseAppsCountdown 120 -PersistPrompt -MinimizeWindows $false'

    Install = {
        Execute-MSI -Action Install -Path $PSScriptRoot\Files\%%INSTALLERNAME%%
    }

    Uninstall = {
        Execute-MSI -Action Uninstall -Path '%%ProductCode%%'
    }

    RemovePreviousVersionDeployments = $true

    DetectionRules = {

        RegistryValue {
            Hive = 'LocalMachine'
            KeyName = "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" + '%%ProductCode%%'
            ValueName = 'DisplayVersion'
            PropertyType = 'Version'
            ExpressionOperator = 'GreaterEquals'
            ExpectedValue = '%%Version%%'
        }

        File {
            FileName = 'AcroRd32.exe'
            Path = "%ProgramFiles%\Adobe\Reader DC\Reader"
        }
    }

    TaskSequences = 'Post-WinPE', 'Post-WinPE-Senior'
    VersionsToKeep = 3
    Intune = {
        User = 'packaging@contoso.com'
        Password = $env:IntunePass
        Tenant = 'contoso.com'
        RemovePreviousAssignments = $true
        Assignments = {
            Assign {
                Group = 'AllDevices'
                Intent = 'Available'
            }

            Assign {
                Group = 'Adobe Reader DC'
                Intent = 'Required'
            }
        }
    }
}
```

This shows an example of the `Intune` setting. It will deploy the app as available to all devices and required to the **Adobe Reader DC** group. It will also remove the assignments from all previous versions. One other thing to note is the use of an environment variable for the password rather than storing it as plain text in the configuration.

## PARAMETERS

### -Name
The name of the application.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ScriptBlock
The following properties are allowed:

- **URL** (Required) - The URL to the latest version of the application. It can be either a direct link or one that redirects to the latest (See Example 1).
- **Destination** (Required) - The directory where all versions of the app are stored such as `\\contoso.com\apps\Packages\SomeApp` (Do **NOT** specify a specific version such as `\\contoso.com\apps\Packages\SomeApp\1.3.8` since the version directory will be automatically created for each new version.)
- **InstallWelcomeParams** (Required) - Parameters to be used with the [Show-InstallationWelcome](../PS%20ADT%20Cmdlets/Show-InstallationWelcome.md) command during installations. See [Show-InstallationWelcome](../PS%20ADT%20Cmdlets/Show-InstallationWelcome.md) for documentation on its parameters.
- **UninstallWelcomeParams** (Required) - Parameters to be used with the [Show-InstallationWelcome](../PS%20ADT%20Cmdlets/Show-InstallationWelcome.md) command during uninstallations. See [Show-InstallationWelcome](../PS%20ADT%20Cmdlets/Show-InstallationWelcome.md) for documentation on its parameters.
- **Install** (Required) - A scriptblock including all the commands to install the app.
- **Uninstall** (Required) - A scriptblock including all the commands to uninstall the app.
- **DetectionRules** (Required) - A scriptblock including at least one detection rule. Use the `RegistryValue` and `File` commands to define detection rules.
- **SupersedeLastVersion** (Optional) - A scriptblock containing the settings for superseding the previous version of an application.
- **RemovePreviousVersionDeployments** (Optional) - Set to $true if the previous version of the application should have its deployments removed.
- **Metadata** (Optional) - A scriptblock containing key/value pairs for each metadata property. This allows overriding the properties **Manufacturer** and **Version** in the scenario where the installer does not include either the version number and/or the manufacturer.
**Description** (Optional) - A description for the application. A description is required by Intune. If this is not set, it will default to `None.`.
**Icon** (Optional) - The path to the icon file. If not specified, the icon will attempt to be located in the same directory as the configuration script. It will look for a file called `icon` with any file extension. For example, if the configuration script `C:\Packages\Google Chrome\package.ps1` is run, it will look for a file called `icon.*` in `C:\Packages\Google Chrome`.
- **Dependencies** (Optional) - A list of application names that must be installed prior to this application.
- **EstimatedRuntimeMins** (Optional) - Number of minutes the installation is expected to take. Default: 5.
- **MaximumRuntimeMins** (Optional) - Number of minutes to allow installation to run before timing out. Default: 60.
- **PreInstall** (Optional) - A scriptblock containing any commands to run before installing the app.
- **PostInstall** (Optional) - A scriptblock containing any commands to run after installing the app.
- **PreUninstall** (Optional) - A scriptblock containing any commands to run before uninstalling the app.
- **PostUninstall** (Optional) - A scriptblock containing any commands to run after uninstalling the app.
- **Deployments** (Optional) - A scriptblock containing one or more Deploy commands which specified where and how the application is to be deployed.
- **TaskSequences** (Optional) - An array of task sequence names the include an Install Application step. The step will be updated with the new version of the application.
- **VersionsToKeep** (Optional) - The amount of versions to keep. All versions outside of the scope to keep will be removed.
**Intune** (Optional) - A scriptblock containing the settings for Intune.

```yaml
Type: ScriptBlock
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
