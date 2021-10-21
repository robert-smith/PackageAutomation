Update-GroupPolicy
==================

SYNOPSIS
--------

Performs a gpupdate command to refresh Group Policies on the local
machine.

SYNTAX
------

```powershell
Update-GroupPolicy [[-ContinueOnError] <Boolean>] [<CommonParameters>]
```

DESCRIPTION
-----------

Performs a gpupdate command to refresh Group Policies on the local
machine.

PARAMETERS
----------

### -ContinueOnError

**Type**: `<Boolean>`

Continue if an error is encountered. Default is: $true.

-------------------------- EXAMPLE 1 --------------------------

```powershell
PS C:\>Update-GroupPolicy
```
