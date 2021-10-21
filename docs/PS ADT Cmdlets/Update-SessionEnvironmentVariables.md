Update-SessionEnvironmentVariables
==================================

SYNOPSIS
--------

Updates the environment variables for the current PowerShell session
with any environment variable changes that may have occurred during
script execution.

SYNTAX
------

```powershell
Update-SessionEnvironmentVariables [-LoadLoggedOnUserEnvironmentVariables] [[-ContinueOnError] <Boolean>] [<CommonParameters>]
```

DESCRIPTION
-----------

Environment variable changes that take place during script execution are
not visible to the current PowerShell session.

Use this function to refresh the current PowerShell session with all
environment variable settings.

PARAMETERS
----------

### -LoadLoggedOnUserEnvironmentVariables

**Type**: `[<SwitchParameter>]`

If script is running in SYSTEM context, this option allows loading
environment variables from the active console user. If no console user
exists but users are logged in, such as on

terminal servers, then the first logged-in non-console user.

### -ContinueOnError

**Type**: `<Boolean>`

Continue if an error is encountered. Default is: $true.

-------------------------- EXAMPLE 1 --------------------------

```powershell
PS C:\>Update-SessionEnvironmentVariables
```
