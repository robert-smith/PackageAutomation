Set-IniValue
============

SYNOPSIS
--------

Opens an INI file and sets the value of the specified section and key.

SYNTAX
------

```powershell
Set-IniValue [-FilePath] <String> [-Section] <String> [-Key] <String> [-Value] <Object> [[-ContinueOnError] <Boolean>] [<CommonParameters>]
```

DESCRIPTION
-----------

Opens an INI file and sets the value of the specified section and key.

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

### -Value

**Type**: `<Object>`

Value for the key within the section of the INI file. To remove a value,
set this variable to $null.

### -ContinueOnError

**Type**: `<Boolean>`

Continue if an error is encountered. Default is: $true.

-------------------------- EXAMPLE 1 --------------------------

```powershell
PS C:\>Set-IniValue -FilePath "$envProgramFilesX86\IBM\Notes\notes.ini" -Section 'Notes' -Key 'KeyFileName' -Value 'MyFile.ID'
```
