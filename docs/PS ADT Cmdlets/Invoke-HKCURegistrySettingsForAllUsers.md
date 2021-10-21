Invoke-HKCURegistrySettingsForAllUsers
======================================

SYNOPSIS
--------

Set current user registry settings for all current users and any new
users in the future.

SYNTAX
------

```powershell
Invoke-HKCURegistrySettingsForAllUsers [-RegistrySettings] <ScriptBlock> [[-UserProfiles] <PSObject[]>] [<CommonParameters>]
```

DESCRIPTION
-----------

Set HKCU registry settings for all current and future users by loading
their NTUSER.dat registry hive file, and making the modifications.

This function will modify HKCU settings for all users even when executed
under the SYSTEM account.

To ensure new users in the future get the registry edits, the Default
User registry hive used to provision the registry for new users is
modified.

This function can be used as an alternative to using ActiveSetup for
registry settings.

The advantage of using this function over ActiveSetup is that a user
does not have to log off and log back on before the changes take effect.

PARAMETERS
----------

### -RegistrySettings

**Type**: `<ScriptBlock>`

Script block which contains HKCU registry settings which should be
modified for all users on the system. Must specify the -SID parameter
for all HKCU settings.

### -UserProfiles

**Type**: `<PSObject[]>`

Specify the user profiles to modify HKCU registry settings for. Default
is all user profiles except for system profiles.

-------------------------- EXAMPLE 1 --------------------------

```powershell
PS C:\>[scriptblock]$HKCURegistrySettings = {
```

Set-RegistryKey -Key 'HKCU\Software\Microsoft\Office\14.0\Common'
-Name 'qmenable' -Value 0 -Type DWord -SID $UserProfile.SID

Set-RegistryKey -Key 'HKCU\Software\Microsoft\Office\14.0\Common'
-Name 'updatereliabilitydata' -Value 1 -Type DWord -SID $UserProfile.SID

}

Invoke-HKCURegistrySettingsForAllUsers -RegistrySettings
$HKCURegistrySettings
