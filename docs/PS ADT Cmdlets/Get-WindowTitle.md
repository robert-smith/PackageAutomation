Get-WindowTitle
===============

SYNOPSIS
--------

Search for an open window title and return details about the window.

SYNTAX
------

```powershell
Get-WindowTitle -WindowTitle <String> [-DisableFunctionLogging] [<CommonParameters>]

Get-WindowTitle -GetAllWindowTitles [-DisableFunctionLogging] [<CommonParameters>]
```

DESCRIPTION
-----------

Search for a window title. If window title searched for returns more
than one result, then details for each window will be displayed.

Returns the following properties for each window: WindowTitle,
WindowHandle, ParentProcess, ParentProcessMainWindowHandle,
ParentProcessId.

Function does not work in SYSTEM context unless launched with
"psexec.exe -s -i" to run it as an interactive process under the SYSTEM
account.

PARAMETERS
----------

### -WindowTitle

**Type**: `<String>`

The title of the application window to search for using regex matching.

### -GetAllWindowTitles

**Type**: `[<SwitchParameter>]`

Get titles for all open windows on the system.

### -DisableFunctionLogging

**Type**: `[<SwitchParameter>]`

Disables logging messages to the script log file.

-------------------------- EXAMPLE 1 --------------------------

```powershell
PS C:\>Get-WindowTitle -WindowTitle 'Microsoft Word'
```

Gets details for each window that has the words "Microsoft Word" in the
title.

-------------------------- EXAMPLE 2 --------------------------

```powershell
PS C:\>Get-WindowTitle -GetAllWindowTitles
```

Gets details for all windows with a title.

-------------------------- EXAMPLE 3 --------------------------

```powershell
PS C:\>Get-WindowTitle -GetAllWindowTitles | Where-Object { $_.ParentProcess -eq 'WINWORD' }
```

Get details for all windows belonging to Microsoft Word process with
name "WINWORD".
