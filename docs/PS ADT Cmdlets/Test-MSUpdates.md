Test-MSUpdates
==============

SYNOPSIS
--------

Test whether a Microsoft Windows update is installed.

SYNTAX
------

```powershell
Test-MSUpdates [-KBNumber] <String> [[-ContinueOnError] <Boolean>] [<CommonParameters>]
```

DESCRIPTION
-----------

Test whether a Microsoft Windows update is installed.

PARAMETERS
----------

### -KBNumber

**Type**: `<String>`

KBNumber of the update.

### -ContinueOnError

**Type**: `<Boolean>`

Suppress writing log message to console on failure to write message to
log file. Default is: $true.

-------------------------- EXAMPLE 1 --------------------------

```powershell
PS C:\>Test-MSUpdates -KBNumber 'KB2549864'
```
