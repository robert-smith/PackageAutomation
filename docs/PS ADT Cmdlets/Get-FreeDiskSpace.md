Get-FreeDiskSpace
=================

SYNOPSIS
--------

Retrieves the free disk space in MB on a particular drive (defaults to
system drive)

SYNTAX
------

```powershell
Get-FreeDiskSpace [[-Drive] <String>] [[-ContinueOnError] <Boolean>] [<CommonParameters>]
```

DESCRIPTION
-----------

Retrieves the free disk space in MB on a particular drive (defaults to
system drive)

PARAMETERS
----------

### -Drive

**Type**: `<String>`

Drive to check free disk space on

### -ContinueOnError

**Type**: `<Boolean>`

Continue if an error is encountered. Default is: $true.

-------------------------- EXAMPLE 1 --------------------------

```powershell
PS C:\>Get-FreeDiskSpace -Drive 'C:'
```
