Show-InstallationProgress
=========================

SYNOPSIS
--------

Displays a progress dialog in a separate thread with an updateable
custom message.

SYNTAX
------

```powershell
Show-InstallationProgress [[-StatusMessage] <String>] [[-WindowLocation] <String>] [[-TopMost] <Boolean>] [<CommonParameters>]
```

DESCRIPTION
-----------

Create a WPF window in a separate thread to display a marquee style
progress ellipse with a custom message that can be updated.

The status message supports line breaks.

The first time this function is called in a script, it will display a
balloon tip notification to indicate that the installation has started
(provided balloon tips are enabled in the

configuration).

PARAMETERS
----------

### -StatusMessage

**Type**: `<String>`

The status message to be displayed. The default status message is taken
from the XML configuration file.

### -WindowLocation

**Type**: `<String>`

The location of the progress window. Default: just below top, centered.

### -TopMost

**Type**: `<Boolean>`

Specifies whether the progress window should be topmost. Default: $true.

-------------------------- EXAMPLE 1 --------------------------

```powershell
PS C:\>Show-InstallationProgress
```

Uses the default status message from the XML configuration file.

-------------------------- EXAMPLE 2 --------------------------

```powershell
PS C:\>Show-InstallationProgress -StatusMessage 'Installation in Progress...'
```

-------------------------- EXAMPLE 3 --------------------------

```powershell
PS C:\>Show-InstallationProgress -StatusMessage "Installation in Progress...`nThe installation may take 20 minutes to complete."
```

-------------------------- EXAMPLE 4 --------------------------

```powershell
PS C:\>Show-InstallationProgress -StatusMessage 'Installation in Progress...' -WindowLocation 'BottomRight' -TopMost $false
```
