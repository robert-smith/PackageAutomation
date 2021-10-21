Get-UserProfiles
================

SYNOPSIS
--------

Get the User Profile Path, User Account Sid, and the User Account Name
for all users that log onto the machine and also the Default User (which
does not log on).

SYNTAX
------

```powershell
Get-UserProfiles [[-ExcludeNTAccount] <String[]>] [[-ExcludeSystemProfiles] <Boolean>] [-ExcludeDefaultUser] [<CommonParameters>]
```

DESCRIPTION
-----------

Get the User Profile Path, User Account Sid, and the User Account Name
for all users that log onto the machine and also the Default User (which
does not log on).

Please note that the NTAccount property may be empty for some user
profiles but the SID and ProfilePath properties will always be
populated.

PARAMETERS
----------

### -ExcludeNTAccount

**Type**: `<String[]>`

Specify NT account names in Domain\Username format to exclude from the
list of user profiles.

### -ExcludeSystemProfiles

**Type**: `<Boolean>`

Exclude system profiles: SYSTEM, LOCAL SERVICE, NETWORK SERVICE. Default
is: $true.

### -ExcludeDefaultUser

**Type**: `[<SwitchParameter>]`

Exclude the Default User. Default is: $false.

-------------------------- EXAMPLE 1 --------------------------

```powershell
PS C:\>Get-UserProfiles
```

Returns the following properties for each user profile on the system:
NTAccount, SID, ProfilePath

-------------------------- EXAMPLE 2 --------------------------

```powershell
PS C:\>Get-UserProfiles -ExcludeNTAccount 'CONTOSO\Robot','CONTOSO\ntadmin'
```

-------------------------- EXAMPLE 3 --------------------------

```powershell
PS C:\>[string[]]$ProfilePaths = Get-UserProfiles | Select-Object -ExpandProperty 'ProfilePath'
```

Returns the user profile path for each user on the system. This
information can then be used to make modifications under the user
profile on the filesystem.
