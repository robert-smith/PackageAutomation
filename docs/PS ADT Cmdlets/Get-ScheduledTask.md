Get-ScheduledTask
=================

SYNOPSIS
--------

Retrieve all details for scheduled tasks on the local computer.

SYNTAX
------

```powershell
Get-ScheduledTask [[-TaskName] <String>] [[-ContinueOnError] <Boolean>] [<CommonParameters>]
```

DESCRIPTION
-----------

Retrieve all details for scheduled tasks on the local computer using
schtasks.exe. All property names have spaces and colons removed.

PARAMETERS
----------

### -TaskName

**Type**: `<String>`

Specify the name of the scheduled task to retrieve details for. Uses
regex match to find scheduled task.

### -ContinueOnError

**Type**: `<Boolean>`

Continue if an error is encountered. Default: $true.

-------------------------- EXAMPLE 1 --------------------------

```powershell
PS C:\>Get-ScheduledTask
```

To display a list of all scheduled task properties.

-------------------------- EXAMPLE 2 --------------------------

```powershell
PS C:\>Get-ScheduledTask | Out-GridView
```

To display a grid view of all scheduled task properties.

-------------------------- EXAMPLE 3 --------------------------

```powershell
PS C:\>Get-ScheduledTask | Select-Object -Property TaskName
```

To display a list of all scheduled task names.
