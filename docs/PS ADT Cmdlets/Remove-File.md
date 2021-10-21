Remove-File
===========

SYNOPSIS
--------

Removes one or more items from a given path on the filesystem.

SYNTAX
------

```powershell
Remove-File -Path <String[]> [-Recurse] [-ContinueOnError <Boolean>] [<CommonParameters>]

Remove-File -LiteralPath <String[]> [-Recurse] [-ContinueOnError <Boolean>] [<CommonParameters>]
```

DESCRIPTION
-----------

Removes one or more items from a given path on the filesystem.

PARAMETERS
----------

### -Path

**Type**: `<String[]>`

Specifies the path on the filesystem to be resolved. The value of Path
will accept wildcards. Will accept an array of values.

### -LiteralPath

**Type**: `<String[]>`

Specifies the path on the filesystem to be resolved. The value of
LiteralPath is used exactly as it is typed; no characters are
interpreted as wildcards. Will accept an array of values.

### -Recurse

**Type**: `[<SwitchParameter>]`

Deletes the files in the specified location(s) and in all child items of
the location(s).

### -ContinueOnError

**Type**: `<Boolean>`

Continue if an error is encountered. Default is: $true.

-------------------------- EXAMPLE 1 --------------------------

```powershell
PS C:\>Remove-File -Path 'C:\Windows\Downloaded Program Files\Temp.inf'
```

-------------------------- EXAMPLE 2 --------------------------

```powershell
PS C:\>Remove-File -LiteralPath 'C:\Windows\Downloaded Program Files' -Recurse
```
