Get-IniValue
============

SYNOPSIS
--------

Parses an INI file and returns the value of the specified section and
key.

SYNTAX
------

```powershell
Get-IniValue [-FilePath] <String> [-Section] <String> [-Key] <String> [[-ContinueOnError] <Boolean>] [<CommonParameters>]
```

DESCRIPTION
-----------

Parses an INI file and returns the value of the specified section and
key.

PARAMETERS
----------

### -FilePath

**Type**: `<String>`

Path to the INI file.

### -Section

**Type**: `<String>`

Section within the INI file.

### -Key

**Type**: `<String>`

Key within the section of the INI file.

### -ContinueOnError

**Type**: `<Boolean>`

Continue if an error is encountered. Default is: $true.

-------------------------- EXAMPLE 1 --------------------------

```powershell
PS C:\>Get-IniValue -FilePath "$envProgramFilesX86\IBM\Notes\notes.ini" -Section 'Notes' -Key 'KeyFileName'
```
