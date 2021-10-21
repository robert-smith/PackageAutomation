Test-RegistryValue
==================

SYNOPSIS
--------

Test if a registry value exists.

SYNTAX
------

```powershell
Test-RegistryValue [-Key] <Object> [-Value] <Object> [[-SID] <String>] [<CommonParameters>]
```

DESCRIPTION
-----------

Checks a registry key path to see if it has a value with a given name.
Can correctly handle cases where a value simply has an empty or null
value.

PARAMETERS
----------

### -Key

**Type**: `<Object>`

Path of the registry key.

### -Value

**Type**: `<Object>`

Specify the registry key value to check the existence of.

### -SID

**Type**: `<String>`

The security identifier (SID) for a user. Specifying this parameter will
convert a HKEY_CURRENT_USER registry key to the HKEY_USERS\$SID
format.

Specify this parameter from the Invoke-HKCURegistrySettingsForAllUsers
function to read/edit HKCU registry settings for all users on the
system.

-------------------------- EXAMPLE 1 --------------------------

```powershell
PS C:\>Test-RegistryValue -Key 'HKLM:SYSTEM\CurrentControlSet\Control\Session Manager' -Value 'PendingFileRenameOperations'
```
