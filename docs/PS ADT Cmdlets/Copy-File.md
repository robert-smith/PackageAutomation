Copy-File
=========

SYNOPSIS
--------

Copy a file or group of files to a destination path.

SYNTAX
------

```powershell
Copy-File [-Path] <String[]> [-Destination] <String> [-Recurse] [[-ContinueOnError] <Boolean>] [[-ContinueFileCopyOnError] <Boolean>] [<CommonParameters>]
```

DESCRIPTION
-----------

Copy a file or group of files to a destination path.

PARAMETERS
----------

### -Path

**Type**: `<String[]>`

Path of the file to copy.

### -Destination

**Type**: `<String>`

Destination Path of the file to copy.

### -Recurse

**Type**: `[<SwitchParameter>]`

Copy files in subdirectories.

### -ContinueOnError

**Type**: `<Boolean>`

Continue if an error is encountered. This will continue the deployment
script, but will not continue copying files if an error is encountered.
Default is: $true.

### -ContinueFileCopyOnError

**Type**: `<Boolean>`

Continue copying files if an error is encountered. This will continue
the deployment script and will warn about files that failed to be
copied. Default is: $false.

-------------------------- EXAMPLE 1 --------------------------

```powershell
PS C:\>Copy-File -Path "$dirSupportFiles\MyApp.ini" -Destination "$envWindir\MyApp.ini"
```

-------------------------- EXAMPLE 2 --------------------------

```powershell
PS C:\>Copy-File -Path "$dirSupportFiles\*.*" -Destination "$envTemp\tempfiles"
```

Copy all of the files in a folder to a destination folder.
