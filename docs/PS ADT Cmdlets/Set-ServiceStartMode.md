Set-ServiceStartMode
====================

SYNOPSIS
--------

Set the service startup mode.

SYNTAX
------

```powershell
Set-ServiceStartMode [-Name] <String> [[-ComputerName] <String>] [-StartMode] <String> [[-ContinueOnError] <Boolean>] [<CommonParameters>]
```

DESCRIPTION
-----------

Set the service startup mode.

PARAMETERS
----------

### -Name

**Type**: `<String>`

Specify the name of the service.

### -ComputerName

**Type**: `<String>`

Specify the name of the computer. Default is: the local computer.

### -StartMode

**Type**: `<String>`

Specify startup mode for the service. Options: Automatic, Automatic
(Delayed Start), Manual, Disabled, Boot, System.

### -ContinueOnError

**Type**: `<Boolean>`

Continue if an error is encountered. Default is: $true.

-------------------------- EXAMPLE 1 --------------------------

```powershell
PS C:\>Set-ServiceStartMode -Name 'wuauserv' -StartMode 'Automatic (Delayed Start)'
```
