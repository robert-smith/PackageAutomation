Test-ServiceExists
==================

SYNOPSIS
--------

Check to see if a service exists.

SYNTAX
------

```powershell
Test-ServiceExists [-Name] <String> [[-ComputerName] <String>] [-PassThru] [[-ContinueOnError] <Boolean>] [<CommonParameters>]
```

DESCRIPTION
-----------

Check to see if a service exists (using WMI method because Get-Service
will generate ErrorRecord if service doesn't exist).

PARAMETERS
----------

### -Name

**Type**: `<String>`

Specify the name of the service.

Note: Service name can be found by executing "Get-Service | Format-Table
-AutoSize -Wrap" or by using the properties screen of a service in
services.msc.

### -ComputerName

**Type**: `<String>`

Specify the name of the computer. Default is: the local computer.

### -PassThru

**Type**: `[<SwitchParameter>]`

Return the WMI service object.

### -ContinueOnError

**Type**: `<Boolean>`

Continue if an error is encountered. Default is: $true.

-------------------------- EXAMPLE 1 --------------------------

```powershell
PS C:\>Test-ServiceExists -Name 'wuauserv'
```

-------------------------- EXAMPLE 2 --------------------------

```powershell
PS C:\>Test-ServiceExists -Name 'testservice' -PassThru | Where-Object { $_ } | ForEach-Object { $_.Delete() }
```

Check if a service exists and then delete it by using the -PassThru
parameter.
