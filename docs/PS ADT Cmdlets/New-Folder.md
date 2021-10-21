New-Folder
==========

SYNOPSIS
--------

Create a new folder.

SYNTAX
------

```powershell
New-Folder [-Path] <String> [[-ContinueOnError] <Boolean>] [<CommonParameters>]
```

DESCRIPTION
-----------

Create a new folder if it does not exist.

PARAMETERS
----------

### -Path

**Type**: `<String>`

Path to the new folder to create.

### -ContinueOnError

**Type**: `<Boolean>`

Continue if an error is encountered. Default is: $true.

-------------------------- EXAMPLE 1 --------------------------

```powershell
PS C:\>New-Folder -Path "$envWinDir\System32"
```
