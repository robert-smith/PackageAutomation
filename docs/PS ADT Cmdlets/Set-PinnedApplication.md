Set-PinnedApplication
=====================

SYNOPSIS
--------

Pins or unpins a shortcut to the start menu or task bar.

SYNTAX
------

```powershell
Set-PinnedApplication [-Action] <String> [-FilePath] <String> [<CommonParameters>]
```

DESCRIPTION
-----------

Pins or unpins a shortcut to the start menu or task bar.

This should typically be run in the user context, as pinned items are
stored in the user profile.

PARAMETERS
----------

### -Action

**Type**: `<String>`

Action to be performed. Options:
'PintoStartMenu','UnpinfromStartMenu','PintoTaskbar','UnpinfromTaskbar'.

### -FilePath

**Type**: `<String>`

Path to the shortcut file to be pinned or unpinned.

-------------------------- EXAMPLE 1 --------------------------

```powershell
PS C:\>Set-PinnedApplication -Action 'PintoStartMenu' -FilePath "$envProgramFilesX86\IBM\Lotus\Notes\notes.exe"
```

-------------------------- EXAMPLE 2 --------------------------

```powershell
PS C:\>Set-PinnedApplication -Action 'UnpinfromTaskbar' -FilePath "$envProgramFilesX86\IBM\Lotus\Notes\notes.exe"
```
