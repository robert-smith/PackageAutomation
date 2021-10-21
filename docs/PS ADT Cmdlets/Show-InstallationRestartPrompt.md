Show-InstallationRestartPrompt
==============================

SYNOPSIS
--------

Displays a restart prompt with a countdown to a forced restart.

SYNTAX
------

```powershell
Show-InstallationRestartPrompt [[-CountdownSeconds] <Int32>] [[-CountdownNoHideSeconds] <Int32>] [-NoCountdown] [<CommonParameters>]
```

DESCRIPTION
-----------

Displays a restart prompt with a countdown to a forced restart.

PARAMETERS
----------

### -CountdownSeconds

**Type**: `<Int32>`

Specifies the number of seconds to countdown before the system restart.

### -CountdownNoHideSeconds

**Type**: `<Int32>`

Specifies the number of seconds to display the restart prompt without
allowing the window to be hidden.

### -NoCountdown

**Type**: `[<SwitchParameter>]`

Specifies not to show a countdown, just the Restart Now and Restart
Later buttons.

The UI will restore/reposition itself persistently based on the interval
value specified in the config file.

-------------------------- EXAMPLE 1 --------------------------

```powershell
PS C:\>Show-InstallationRestartPrompt -Countdownseconds 600 -CountdownNoHideSeconds 60
```

-------------------------- EXAMPLE 2 --------------------------

```powershell
PS C:\>Show-InstallationRestartPrompt -NoCountdown
```
