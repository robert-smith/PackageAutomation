Remove-RegistryKey
==================

SYNOPSIS
--------

Deletes the specified registry key or value.

SYNTAX
------

```powershell
Remove-RegistryKey [-Key] <String> [[-Name] <String>] [-Recurse] [[-SID] <String>] [[-ContinueOnError] <Boolean>] [<CommonParameters>]
```

DESCRIPTION
-----------

Deletes the specified registry key or value.

PARAMETERS
----------

### -Key

**Type**: `<String>`

Path of the registry key to delete.

### -Name

**Type**: `<String>`

Name of the registry value to delete.

### -Recurse

**Type**: `[<SwitchParameter>]`

Delete registry key recursively.

### -SID

**Type**: `<String>`

The security identifier (SID) for a user. Specifying this parameter will
convert a HKEY_CURRENT_USER registry key to the HKEY_USERS\$SID
format.

Specify this parameter from the Invoke-HKCURegistrySettingsForAllUsers
function to read/edit HKCU registry settings for all users on the
system.

### -ContinueOnError

**Type**: `<Boolean>`

Continue if an error is encountered. Default is: $true.

-------------------------- EXAMPLE 1 --------------------------

```powershell
PS C:\>Remove-RegistryKey -Key 'HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\RunOnce'
```

-------------------------- EXAMPLE 2 --------------------------

```powershell
PS C:\>Remove-RegistryKey -Key 'HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\Run' -Name 'RunAppInstall'
```
