Remove-Folder
=============

SYNOPSIS
--------

Remove folder and files if they exist.

SYNTAX
------

```powershell
Remove-Folder [-Path] <String> [[-ContinueOnError] <Boolean>] [<CommonParameters>]
```

DESCRIPTION
-----------

Remove folder and all files recursively in a given path.

PARAMETERS
----------

### -Path

**Type**: `<String>`

Path to the folder to remove.

### -ContinueOnError

**Type**: `<Boolean>`

Continue if an error is encountered. Default is: $true.

-------------------------- EXAMPLE 1 --------------------------

```powershell
PS C:\>Remove-Folder -Path "$envWinDir\Downloaded Program Files"
```
