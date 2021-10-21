Get-FileVersion
===============

SYNOPSIS
--------

Gets the version of the specified file

SYNTAX
------

```powershell
Get-FileVersion [-File] <String> [[-ContinueOnError] <Boolean>] [<CommonParameters>]
```

DESCRIPTION
-----------

Gets the version of the specified file

PARAMETERS
----------

### -File

**Type**: `<String>`

Path of the file

### -ContinueOnError

**Type**: `<Boolean>`

Continue if an error is encountered. Default is: $true.

-------------------------- EXAMPLE 1 --------------------------

```powershell
PS C:\>Get-FileVersion -File "$envProgramFilesX86\Adobe\Reader 11.0\Reader\AcroRd32.exe"
```
