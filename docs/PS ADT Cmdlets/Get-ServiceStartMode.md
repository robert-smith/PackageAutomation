Get-ServiceStartMode
====================

SYNOPSIS
--------

Get the service startup mode.

SYNTAX
------

```powershell
Get-ServiceStartMode [-Name] <String> [[-ComputerName] <String>] [[-ContinueOnError] <Boolean>] [<CommonParameters>]
```

DESCRIPTION
-----------

Get the service startup mode.

PARAMETERS
----------

### -Name

**Type**: `<String>`

Specify the name of the service.

### -ComputerName

**Type**: `<String>`

Specify the name of the computer. Default is: the local computer.

### -ContinueOnError

**Type**: `<Boolean>`

Continue if an error is encountered. Default is: $true.

-------------------------- EXAMPLE 1 --------------------------

```powershell
PS C:\>Get-ServiceStartMode -Name 'wuauserv'
```
