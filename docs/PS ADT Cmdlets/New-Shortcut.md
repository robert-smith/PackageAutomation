New-Shortcut
============

SYNOPSIS
--------

Creates a new .lnk or .url type shortcut

SYNTAX
------

```powershell
New-Shortcut [-Path] <String> [-TargetPath] <String> [[-Arguments] <String>] [[-IconLocation] <String>] [[-IconIndex] <String>] [[-Description] <String>] [[-WorkingDirectory] <String>] [[-WindowStyle] <String>] [-RunAsAdmin] [[-Hotkey] <String>] [[-ContinueOnError] <Boolean>] [<CommonParameters>]
```

DESCRIPTION
-----------

Creates a new shortcut .lnk or .url file, with configurable options

PARAMETERS
----------

### -Path

**Type**: `<String>`

Path to save the shortcut

### -TargetPath

**Type**: `<String>`

Target path or URL that the shortcut launches

### -Arguments

**Type**: `<String>`

Arguments to be passed to the target path

### -IconLocation

**Type**: `<String>`

Location of the icon used for the shortcut

### -IconIndex

**Type**: `<String>`

Executables, DLLs, ICO files with multiple icons need the icon index to
be specified

### -Description

**Type**: `<String>`

Description of the shortcut

### -WorkingDirectory

**Type**: `<String>`

Working Directory to be used for the target path

### -WindowStyle

**Type**: `<String>`

Windows style of the application. Options: Normal, Maximized, Minimized.
Default is: Normal.

### -RunAsAdmin

**Type**: `[<SwitchParameter>]`

Set shortcut to run program as administrator. This option will prompt
user to elevate when executing shortcut.

### -Hotkey

**Type**: `<String>`

Create a Hotkey to launch the shortcut, e.g. "CTRL+SHIFT+F"

### -ContinueOnError

**Type**: `<Boolean>`

Continue if an error is encountered. Default is: $true.

-------------------------- EXAMPLE 1 --------------------------

```powershell
PS C:\>New-Shortcut -Path "$envProgramData\Microsoft\Windows\Start Menu\My Shortcut.lnk" -TargetPath "$envWinDir\system32\notepad.exe" -IconLocation "$envWinDir\system32\notepad.exe"
```

-Description 'Notepad' -WorkingDirectory "$envHomeDrive\$envHomePath"
