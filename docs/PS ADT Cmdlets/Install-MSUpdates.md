Install-MSUpdates
=================

SYNOPSIS
--------

Install all Microsoft Updates in a given directory.

SYNTAX
------

```powershell
Install-MSUpdates [-Directory] <String> [<CommonParameters>]
```

DESCRIPTION
-----------

Install all Microsoft Updates of type ".exe", ".msu", or ".msp" in a
given directory (recursively search directory).

PARAMETERS
----------

### -Directory

**Type**: `<String>`

Directory containing the updates.

-------------------------- EXAMPLE 1 --------------------------

```powershell
PS C:\>Install-MSUpdates -Directory "$dirFiles\MSUpdates"
```
