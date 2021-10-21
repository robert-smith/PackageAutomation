Exit-Script
===========

SYNOPSIS
--------

Exit the script, perform cleanup actions, and pass an exit code to the
parent process.

SYNTAX
------

```powershell
Exit-Script [[-ExitCode] <Int32>] [<CommonParameters>]
```

DESCRIPTION
-----------

Always use when exiting the script to ensure cleanup actions are
performed.

PARAMETERS
----------

### -ExitCode

**Type**: `<Int32>`

The exit code to be passed from the script to the parent process, e.g.
SCCM
----

-------------------------- EXAMPLE 1 --------------------------

```powershell
PS C:\>Exit-Script -ExitCode 0
```

-------------------------- EXAMPLE 2 --------------------------

```powershell
PS C:\>Exit-Script -ExitCode 1618
```
