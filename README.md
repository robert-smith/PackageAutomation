PackageAutomation
=================

Description
-----------

Provides a [domain-specific language](https://en.wikipedia.org/wiki/Domain-specific_language) for packaging new versions of apps. The goal of this module is to make easy to read and write scripts that automatically download, package, and deploy new versions of software. This module is currently used for the [AutoPackaging](https://gitlab.contoso.com/Services/AutoPackaging) project on [GitLab](https://gitlab.contoso.com).

Getting Started
---------------

### Prereqs

- SCCM PowerShell module. To install this, just install the SCCM console.
- **AzureAD** Powershell module
- **PSIntuneAuth** PowerShell module

Setup
-----

Before `Application` can be run for any application, there are some things that **must** be setup. Otherwise, the command will fail.

1. The directory where the application versions are to be stored must be created.

   **Example**: If creating an Application script for the **SomeApp** application, the following directory would need to be created first: `\\contoso.com\Packages\SomeApp`

2. An icon image must be provided. The easiest method is to have an image file called `icon.*` included in the same directory as the script that contains the `Application` configuration script. Alternatively, you can also specify the `Icon` setting in the configuration with the path to the icon image. Images must **not** be larger than 250x250px.

Usage
-----

The `Application` command is the main command in this module. Each time this command is run, it will automatically check for new updates for the specified application, download the latest installer, create a silent package using the supplied install/uninstall commands, create a new application, distribute content, and finally deploy the new application. This command was designed to be run periodically automatically using a runner such as [Jenkins](https://jenkins.io) or the [GitLab runner](https://docs.gitlab.com/runner/).

**NOTE**: This module makes use of the [PowerShell Application Deployment Toolkit](https://psappdeploytoolkit.com/). See the **PS ADT Cmdlets** folder page for more information on how it is incorporated and how to use its features when creating Application scripts.

### Syntax

**NOTE**: Do no include the angle brackets (`<>`).

```powershell
Application <Name of application> {
    <ScriptBlock>
}
```

### The ScriptBlock Section

The ScriptBlock section of the application command has many parameters, but they are not available to intellisense. This section goes over all of the different parameters that can be defined.

#### Placeholders

Inside the certain parts of the ScriptBlock section, there are placeholders that can be used. These placeholders will be replaced with the values of the application being packaged. For example, if a new version of an application is `1.0.0`, when this module goes to package it, it will replace any instance of `%%VERSION%%` with `1.0.0` before packaging happens.

Placeholders can be used inside the following sections:

- [PreInstall](#preinstall)
- [Install](#install)
- [PostInstall](#postinstall)
- [PreUninstall](#preuninstall)
- [Uninstall](#uninstall)
- [PostUninstall](#postuninstall)

| Placeholder         | Description                                      | Example Value                                                                          |
| ------------------- | ------------------------------------------------ | -------------------------------------------------------------------------------------- |
| `%%PRODUCTCODE%%`   | The MSI product code if the installer is an MSI. | `{67feb1e2-5e43-4644-ae33-36934aee2967}`                                               |
| `%%VERSION%%`       | The version of the application.                  | `10.6.8`                                                                               |
| `%%INSTALLERPATH%%` | The full path to the packaged installer.         | `\\contoso.com\packages\Pearson\TestNav\10.6.8\Files\testnav-10.6.8.exe` |
| `%%INSTALLERNAME%%` | The name of the installer.                       | `testnav-10.6.8.exe`                                                                   |

#### Parameters

The `ScriptBlock` parameter accepts the following parameters inside of a scriptblock:

##### URL

- **Type**: String
- **Description**: The URL where the latest version can be found for the application. This will also accept URLs that redirect to the latest version. Example: To download the latest version of _Visual Studio Code_, the URL `https://update.code.visualstudio.com/latest/win32-x64/stable` can be used which always redirects to the latest version. The latest version URL may need to be extracted from a web page before it can be supplied in the parameter. See [Example 2](#example-2) to see how this can be done before running the `Application` command in a script.

##### Destination

- **Type**: String
- **Description**: The network path where the package should be stored. This is **_not_** the final destination, but the **parent** directory. For example, the destination for **SomeApp** would be `\\contoso.com\Packages\SomeApp`. `Application` will automatically create a directory under that path named after the version number for the latest version of the application. An example of the tree structure after multiple versions have been automatically packaged would be:

    ```text
    \\contoso.com\Packages\SomeApp
    ├───1.27
    ├───1.34.0
    ├───1.35.0
    ├───1.35.1
    ├───1.36.0
    ├───1.36.1
    ├───1.37.1
    ├───1.38.0
    ├───1.39.2
    ```

##### Metadata

- **Type**: Scriptblock
- **Description**: A scriptblock containing keys to override the installer metadata. If `Version` is specified, it will assume that the version is **not** in the installer's file name and append it. This is because the file name of the installer in the download URL is compared to what is already downloaded to avoid downloading the installer each run.

**Example**:

```powershell
Metadata = {
    Manufacturer = 'Adobe Inc.'
}
```

This will override the **Manufacturer** value to `Adobe Inc.`.

##### Description
- **Type**: String
- **Description**: A description for the application. A description is required by Intune. If this is not set, it will default to `None.`.

##### Icon
- **Type**: String
- **Description**: The path to the icon file. If not specified, the icon will attempt to be located in the same directory as the configuration script. It will look for a file called `icon` with any file extension. For example, if the configuration script `C:\Packages\Google Chrome\package.ps1` is run, it will look for a file called `icon.*` in `C:\Packages\Google Chrome`.

##### InstallWelcomeParams

- **Type**: String
- **Description**: A single string containing all the desired parameters for the [Show-InstallationWelcome](PS%20ADT%20Cmdlets/Show-InstallationWelcome.md) command. These parameters will be used during **installations**. The parameters **_must_** be inside of **single** quotes (`'`).

Example:

```powershell
InstallWelcomeParams = '-CloseApps "code=Visual Studio Code" -PersistPrompt -MinimizeWindows $false'
```

##### UninstallWelcomeParams

- **Type**: String
- **Description**: A single string containing all the desired parameters for the [Show-InstallationWelcome](PS%20ADT%20Cmdlets/Show-InstallationWelcome.md) command. These parameters will be used during **uninstallations**. The parameters **_must_** be inside of **single** quotes (`'`).

Example:

```powershell
UninstallWelcomeParams = '-CloseApps "code=Visual Studio Code" -CloseAppsCountdown 120 -PersistPrompt'
```

This will pop up a dialog if `code.exe` is running. The dialog will not be dismissible until the installation has taken place. If `code.exe` is not closed in 2 minutes, it will be force closed.

##### PreInstall

- **Type**: ScriptBlock
- **Description**: A scriptblock containing the commands to run before running the [Install](#install) commands.

##### Install

- **Type**: ScriptBlock
- **Description**: A scriptblock containing the commands to run to install the application. See **PS ADT Cmdlets** folder for a list of commands that the **PowerShell Application Deployment Toolkit** offers to make installing applications easier.

##### PostInstall

- **Type**: ScriptBlock
- **Description**: A scriptblock containing the commands to run after running the [Install](#install) commands.

##### PreUninstall

- **Type**: ScriptBlock
- **Description**: A scriptblock containing the commands to run before running the [Uninstall](#uninstall) commands.

##### Uninstall

- **Type**: ScriptBlock
- **Description**: A scriptblock containing the commands to run to uninstall the application. See **PS ADT Cmdlets** folder for a list of commands that the **PowerShell Application Deployment Toolkit** offers to make uninstalling applications easier.

##### PostUninstall

- **Type**: ScriptBlock
- **Description**: A scriptblock containing the commands to run after running the [Uninstall](#uninstall) commands.

##### SupersedeLastVersion

- **Type**: Scriptblock
- **Description**: A scriptblock containing the settings for superseding the previous version of an application. See below for description of each setting.

##### RemovePreviousVersionDeployments

- **Type**: Boolean
- **Description**: If **true**, will remove the deployments for the previous version of the application.

###### Enabled

- **Type**: Boolean
- **Description**: If **true**, will enable supersedence of the previous application version.

###### Uninstall

- **Type**: Boolean
- **Description**: If **true**, will have SCCM uninstall the previous version before installing the new one.

**WARNING**: Setting `Uninstall` to **true** can have major consequences if being deployed as available. Do **not** use this setting unless you are sure.

##### Dependencies

- **Type**: String[]
- **Description**: A single string or array of strings separated by commas with the base names of each application that the current application depends upon. The name should be the full name of dependent application without any version numbers. This will search SCCM for all applications that contain that name and choose the one with the greatest version number to be added as a dependency.

Single string example:

```powershell
Dependencies = 'Adobe Reader DC'
```

Array example:

```powershell
Dependencies = 'Adobe Reader DC', 'Git'
```

##### DetectionRules

- **Type**: ScriptBlock
- **Description**: This scriptblock must contain one or more detection method commands. See below for commands that should be used and their parameters.

###### File

The `File` detection method command creates a detection method for a file at a specific path.

Parameters:

- **FileName**: The name and extension of the file that should be present.
- **Path**: The path where the `FileName` should be.
  
The following parameters are optional, **but** if one is used, they are all **required**:

- **PropertyType** (Optional): The type of file property. Accepted values are:
  - DateCreated
  - DateModified
  - Size
  - Version
- **ExpectedValue** (Optional): The value that the property should have.
- **ExpressionOperator** (Optional): The operator for comparing the value with the `ExpectedValue`. Accepted values:
  - Between
  - ExcludesAll
  - GreaterEquals
  - GreaterThan
  - IsEquals
  - LessEquals
  - LessThan
  - NoneOf
  - NotBetween
  - NotEquals
  - OneOf

Example usage 1:

This will check for the existence of `C:\Program Files\SomeApp\SomeApp.exe`.

```powershell
DetectionRules {
    File {
        FileName = 'SomeApp.exe'
        Path = '%PROGRAMFILE%\SomeApp'
    }
}
```

Example usage 2:

This will check for the existence of `SomeApp.exe` that is greater than or equal to the latest version through use of the `%%VERSION%%` placeholder.

```powershell
DetectionRules = {
    File {
        FileName = 'SomeApp.exe'
        Path = '%PROGRAMFILE%\SomeApp'
        PropertyType = 'Version'
        ExpressionOperator = 'GreaterEquals'
        ExpectedValue = '%%VERSION%%'
    }
}
```

###### RegistryValue

The `RegistryValue` detection method command creates a detection method for a registry key and its expected value.

Parameters:

- **Hive**: The name of the registry hive. Accepted values are:
  - ClassesRoot
  - CurrentConfig
  - CurrentUser
  - LocalMachine
  - Users
- **KeyName**: The registry path to the key.
- **ValueName**: The registry key's property name.
- **PropertyType**: The expected type of the property. Accepted values are:
  - Boolean
  - DateTime
  - FloatingPoint
  - Integer
  - IntegerArray
  - String
  - StringArray
  - Version
- **ExpressionOperator**: The operator for comparing the value with the `ExpectedValue`. Accepted values:
  - AllOf
  - And
  - BeginsWith
  - Between
  - Contains
  - EndsWith
  - ExcludesAll
  - GreaterEquals
  - GreaterThan
  - IsEquals
  - LessEquals
  - LessThan
  - NoneOf
  - NotBeginsWith
  - NotBetween
  - NotContains
  - NotEndsWith
  - NotEquals
  - OneOf
  - Or
  - Other
  - SetEquals
  - SubsetOf
- **ExpectedValue**: The value that the property should have.

Example usage:

This will check for the existence of the registry key `HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\SomeApp\DisplayVersion` with a value that is greater than or equal to the latest version of the application.

```powershell
DetectionRules = {
    RegistryValue {
        Hive = 'LocalMachine'
        KeyName = 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\SomeApp'
        ValueName = 'DisplayVersion'
        PropertyType = 'Version'
        ExpressionOperator = 'GreaterEquals'
        ExpectedValue = '%%VERSION%%'
    }
}
```

##### Deployments

- **Type**: Scriptblock
- **Description**: A scriptblock containing a list of names and values for each of the corresponding parameters for the `New-CMApplicationDeployment` command. For a list of all available parameters, see <https://docs.microsoft.com/en-us/powershell/module/configurationmanager/new-cmapplicationdeployment?view=sccm-ps>

Example usage:

This will deploy an application as **required** to a collection with the same name as the application. It will also deploy as available to a collection called **All Contoso Clients**.

**NOTE**: Certain parameters are required depending on the `DeployPurpose` mode. In the example below, `OverrideServiceWindow` and `RebootOutsideServiceWindow` must be set for **Required** deployments but not for **Available**.

```powershell
Deployments = {
        Deploy {
            DeployPurpose = 'Required'
            CollectionName = '%%APPNAME%%'
            OverrideServiceWindow = $true
            RebootOutsideServiceWindow = $false
        }

        Deply {
            DeployPurpose = 'Available'
            CollectionName = 'All Contoso Clients'
        }
    }
```

##### TaskSequences

- **Type**: String[]
- **Description**: An array of task sequence names that include an Install Application step. The step will be updated with the latest version of the application.

Example usage:

```powershell
TaskSequences = 'Post-WinPE', 'Post-WinPE-USB'
```

##### VersionsToKeep

- **Type**: Integer
- **Description**: The amount of versions of the application to keep. All older versions that fall outside the scope to keep will be removed.

##### Intune

- **Type**: ScriptBlock
- **Description**: A scriptblock containing the settings for Intune. See the different settings below.

| Name                      | Type        | Description                                                                                                 |
| ------------------------- | ----------- | ----------------------------------------------------------------------------------------------------------- |
| User                      | String      | The UPN of the user with rights to add applications to Intune                                               |
| Password                  | String      | The password of the user. It is **highly** recommended to not include this plain text, but with a variable. |
| Tenant                    | String      | The domain name of the tenant. I.E. `contoso.com`                                                           |
| RemovePreviousAssignments | Boolean     | If true, this will remove all assignments from all older versions.                                          |
| Assignments               | ScriptBlock | A scriptblock containing one or more assignments for deployment. See Assignments section below.             |

###### Assignments

The `Assignments` setting accepts a scriptblock with one or more `Assign` commands. **If any commands other than Assign are detected, it will throw an error.** The `Assign` scriptblock accepts the following settings:

| Setting                      | Required | Type     | Description                                                                                                                                                                                            |
| ---------------------------- | -------- | -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Group                        | Yes      | String   | The name of a group to assign the app to. Use `AllDevices` to assign it to all devices, `AllUsers` for all users, or the name of a group.                                                              |
| Intent                       | Yes      | String   | The type of deployment. Accepted values: `Available` or `Required`.                                                                                                                                    |
| Exclude                      | No       | Boolean  | If true, the specified group will be excluded from assignment.                                                                                                                                         |
| Notification                 | No       | String   | The level of notifications to display when installing the application. Accepted value: `HideAll`, `ShowAll`, or `ShowReboot`.                                                                          |
| DeliveryOptimizationPriority | No       | String   | The priority to take when downloading the application to a device. Accepted values: `Foreground`, `notConfigured`.                                                                                     |
| RestartNotificationSnooze    | No       | Int      | Specify a count in minutes for snoozing the restart notification, if not specified the snooze functionality is now allowed.                                                                            |
| RestartCountDownDisplay      | No       | Int      | Specify a count in minutes when the restart count down display box is shown.                                                                                                                           |
| RestartGracePeriod           | No       | Int      | Specify the device restart grace period in minutes.                                                                                                                                                    |
| EnableRestartGracePeriod     | No       | Boolean  | Specify whether Restart Grace Period functionality for this assignment should be configured, additional parameter input using at least `RestartGracePeriod` and `RestartCountDownDisplay` is required. |
| AvailableTime                | No       | DateTime | Specify a date time object for the availability of the assignment.                                                                                                                                     |
| DeadlineTime                 | No       | DateTime | Specify a date time object for the deadline of the assignment.                                                                                                                                         |
| UseLocalTime                 | No       | Boolean  | Specify to use either UTC of device local time for the assignment, set to 'True' for device local time and 'False' for UTC.                                                                            |

### Example 1

```powershell
Application 'VEXcode IQ Blocks' {
    URL = 'https://link.vex.com/vexcode-iq-blocks-msi'
    Destination = '\\contoso.com\Packages\VEX\Code\IQ Blocks'
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

This will create new versions of the **VEXcode IQ Blocks** app any time this is run and a newer version is available. The URL specified is provided by the developer and always redirects to the latest version of the software. The previous version of **VEXcode IQ Blocks** will be superseded, but not automatically uninstalled.

### Example 2

```powershell
Application 'VEXcode IQ Blocks' {
    URL = 'https://link.vex.com/vexcode-iq-blocks-msi'
    Destination = '\\contoso.com\Packages\VEX\Code\IQ Blocks'
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
    Dependencies = 'Adobe Reader DC'
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
    Deployments = {
        Deploy {
            DeployPurpose = 'Required'
            CollectionName = '%%APPNAME%%'
            OverrideServiceWindow = $true
            RebootOutsideServiceWindow = $false
        }
        Deploy {
            DeployPurpose = 'Available'
            CollectionName = 'All Contoso Clients'
        }
    }
}
```

This will create the same application as in example 1, but it will make the latest version it finds of **Adobe Reader DC** in SCCM a dependency. The application will be deployed as required to a collection with the same name as itself and deployed as available to the **All Contoso Clients** collection.

### Example 3

```powershell
$Latest = Invoke-RestMethod -Uri 'https://api.github.com/repos/git-for-windows/git/releases/latest'
$Global:Download = $Latest.assets.Where{$_.name -like '*64-bit.exe'}.browser_download_url

Application 'Git' {
    URL = $Download
    Destination = '\\contoso.com\Packages\Git'
    Description = 'A free and open source distributed version control system designed to handle everything from small to very large projects with speed and efficiency. Git is easy to learn and has a tiny footprint with lightning fast performance.'
    InstallWelcomeParams = '-CloseApps "git,git-bash,git-cmd" -AllowDeferCloseApps -DeferTimes 3 -PersistPrompt -MinimizeWindows $false'
    Install = {
       Start-Process -FilePath "$PSScriptRoot\Files\%%INSTALLERNAME%%" -ArgumentList "/VERYSILENT /NORESTART /LOADINF=`"$PSScriptRoot\Files\silent.inf`"" -Wait
    }
    UninstallWelcomeParams = '-CloseApps "git,git-bash,git-cmd" -PersistPrompt -MinimizeWindows $false'
    Uninstall = {
       Start-Process -FilePath "$env:ProgramFiles\Git\unins000.exe" -ArgumentList "/VERYSILENT /NORESTART" -Wait
    }
    RemovePreviousVersionDeployments = $true
    Deployments = {
        Deploy {
            CollectionName = 'All Clients'
            DeployPurpose = 'Available' # Available, Required
        }
    }
    DetectionRules = {       
      File {
           FileName = 'git-bash.exe'
           Path = '%PROGRAMFILES%\Git'
           PropertyType = 'Version'
           ExpectedValue = '%%VERSION%%'
           ExpressionOperator = 'IsEquals'
      }
      File {
           FileName = 'git-cmd.exe'
           Path = '%PROGRAMFILES%\Git'
           PropertyType = 'Version'
           ExpectedValue = '%%VERSION%%'
           ExpressionOperator = 'IsEquals'
      }
      File {
           FileName = 'git.exe'
           Path = '%PROGRAMFILES%\Git\mingw64\bin'
           PropertyType = 'Version'
           ExpectedValue = '%%VERSION%%'
           ExpressionOperator = 'IsEquals'
      }
    }
    VersionsToKeep = 3
    Intune = {
        User = $env:IntuneUser
        Password = $env:IntunePass
        Tenant = 'contoso.com'
        RemovePreviousAssignments = $true
        Assignments = {
            Assign {
                Group = 'AllUsers'
                Intent = 'Available'
                Notification = 'ShowReboot'
                DeliveryOptimizationPriority = 'Foreground'
            }
        }
    }
}
```

This is a more advance, but real-world example of a configuration for **Git**. A generic URL is not provided for the latest version of **Git** so it must be extracted from their Github releases. The download URL is stored in a **Global** variable so that it can be used the module.

There is also a second detection method involved. This shows the use of both the registry and file detection methods. Any number of detection methods can be defined in the `DetectionRules` property. If multiple detection methods are specified, they must all be true in order for the app to be detected.

### Example 4

```powershell
Application 'Adobe Reader DC' {
    URL = $DownloadURL
    Destination = '\\contoso.com\Packages\Adobe\Reader\DC'
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
    Destination = '\\contoso.com\Packages\Adobe\Reader\DC'
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