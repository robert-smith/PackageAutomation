Show-BalloonTip
===============

SYNOPSIS
--------

Displays a balloon tip notification in the system tray.

SYNTAX
------

```powershell
Show-BalloonTip [-BalloonTipText] <String> [[-BalloonTipTitle] <String>] [[-BalloonTipIcon] {None | Info | Warning | Error}] [[-BalloonTipTime] <Int32>] [<CommonParameters>]
```

DESCRIPTION
-----------

Displays a balloon tip notification in the system tray.

PARAMETERS
----------

### -BalloonTipText

**Type**: `<String>`

Text of the balloon tip.

### -BalloonTipTitle

**Type**: `<String>`

Title of the balloon tip.

-BalloonTipIcon

Icon to be used. Options: 'Error', 'Info', 'None', 'Warning'. Default
is: Info.

### -BalloonTipTime

**Type**: `<Int32>`

Time in milliseconds to display the balloon tip. Default: 500.

-------------------------- EXAMPLE 1 --------------------------

```powershell
PS C:\>Show-BalloonTip -BalloonTipText 'Installation Started' -BalloonTipTitle 'Application Name'
```

-------------------------- EXAMPLE 2 --------------------------

```powershell
PS C:\>Show-BalloonTip -BalloonTipIcon 'Info' -BalloonTipText 'Installation Started' -BalloonTipTitle 'Application Name' -BalloonTipTime 1000
```
