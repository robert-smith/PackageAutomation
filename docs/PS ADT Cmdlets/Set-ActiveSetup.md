Set-ActiveSetup
===============

SYNOPSIS
--------

Creates an Active Setup entry in the registry to execute a file for each
user upon login.

SYNTAX
------

```powershell
Set-ActiveSetup -StubExePath <String> [-Arguments <String>] [-Description <String>] [-Key <String>] [-Version <String>] [-Locale <String>] [-DisableActiveSetup] [-ContinueOnError <Boolean>] [<CommonParameters>]

Set-ActiveSetup [-Key <String>] -PurgeActiveSetupKey [-ContinueOnError <Boolean>] [<CommonParameters>]
```

DESCRIPTION
-----------

Active Setup allows handling of per-user changes registry/file changes
upon login.

A registry key is created in the HKLM registry hive which gets
replicated to the HKCU hive when a user logs in.

If the "Version" value of the Active Setup entry in HKLM is higher than
the version value in HKCU, the file referenced in "StubPath" is
executed.

This Function:

- Creates the registry entries in HKLM:SOFTWARE\Microsoft\Active
Setup\Installed Components\$installName.

- Creates StubPath value depending on the file extension of the
$StubExePath parameter.

- Handles Version value with YYYYMMDDHHMMSS granularity to permit
re-installs on the same day and still trigger Active Setup after Version
increase.

- Copies/overwrites the StubPath file to $StubExePath destination path
if file exists in 'Files' subdirectory of script directory.

- Executes the StubPath file for the current user as long as not in
Session 0 (no need to logout/login to trigger Active Setup).

PARAMETERS
----------

### -StubExePath

**Type**: `<String>`

Full destination path to the file that will be executed for each user
that logs in.

If this file exists in the 'Files' subdirectory of the script directory,
it will be copied to the destination path.

### -Arguments

**Type**: `<String>`

Arguments to pass to the file being executed.

### -Description

**Type**: `<String>`

Description for the Active Setup. Users will see "Setting up
personalized settings for: $Description" at logon. Default is:
$installName.

### -Key

**Type**: `<String>`

Name of the registry key for the Active Setup entry. Default is:
$installName.

### -Version

**Type**: `<String>`

Optional. Specify version for Active setup entry. Active Setup is not
triggered if Version value has more than 8 consecutive digits. Use
commas to get around this limitation.

### -Locale

**Type**: `<String>`

Optional. Arbitrary string used to specify the installation language of
the file being executed. Not replicated to HKCU.

### -DisableActiveSetup

**Type**: `[<SwitchParameter>]`

Disables the Active Setup entry so that the StubPath file will not be
executed.

### -PurgeActiveSetupKey

**Type**: `[<SwitchParameter>]`

Remove Active Setup entry from HKLM registry hive. Will also load each
logon user's HKCU registry hive to remove Active Setup entry.

### -ContinueOnError

**Type**: `<Boolean>`

Continue if an error is encountered. Default is: $true.

-------------------------- EXAMPLE 1 --------------------------

```powershell
PS C:\>Set-ActiveSetup -StubExePath 'C:\Users\Public\Company\ProgramUserConfig.vbs' -Arguments '/Silent' -Description 'Program User Config' -Key 'ProgramUserConfig' -Locale 'en'
```

-------------------------- EXAMPLE 2 --------------------------

```powershell
PS C:\>Set-ActiveSetup -StubExePath "$envWinDir\regedit.exe" -Arguments "/S `"%SystemDrive%\Program Files (x86)\PS App Deploy\PSAppDeployHKCUSettings.reg`"" -Description 'PS App Deploy Config'
```

-Key 'PS_App_Deploy_Config' -ContinueOnError $true

-------------------------- EXAMPLE 3 --------------------------

```powershell
PS C:\>Set-ActiveSetup -Key 'ProgramUserConfig' -PurgeActiveSetupKey
```

Deletes "ProgramUserConfig" active setup entry from all registry hives.
