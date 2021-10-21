Execute-ProcessAsUser
=====================

SYNOPSIS
--------

Execute a process with a logged in user account, by using a scheduled
task, to provide interaction with user in the SYSTEM context.

SYNTAX
------

```powershell
Execute-ProcessAsUser [[-UserName] <String>] [-Path] <String> [[-Parameters] <String>] [-SecureParameters] [[-RunLevel] <String>] [-Wait] [-PassThru] [[-ContinueOnError] <Boolean>] [<CommonParameters>]
```

DESCRIPTION
-----------

Execute a process with a logged in user account, by using a scheduled
task, to provide interaction with user in the SYSTEM context.

PARAMETERS
----------

### -UserName

**Type**: `<String>`

Logged in Username under which to run the process from. Default is: The
active console user. If no console user exists but users are logged in,
such as on terminal servers, then the first

logged-in non-console user.

### -Path

**Type**: `<String>`

Path to the file being executed.

### -Parameters

**Type**: `<String>`

Arguments to be passed to the file being executed.

### -SecureParameters

**Type**: `[<SwitchParameter>]`

Hides all parameters passed to the executable from the Toolkit log file.

### -RunLevel

**Type**: `<String>`

Specifies the level of user rights that Task Scheduler uses to run the
task. The acceptable values for this parameter are:

- HighestAvailable: Tasks run by using the highest available privileges
(Admin privileges for Administrators). Default Value.

- LeastPrivilege: Tasks run by using the least-privileged user account
(LUA) privileges.

### -Wait

**Type**: `[<SwitchParameter>]`

Wait for the process, launched by the scheduled task, to complete
execution before accepting more input. Default is $false.

### -PassThru

**Type**: `[<SwitchParameter>]`

Returns the exit code from this function or the process launched by the
scheduled task.

### -ContinueOnError

**Type**: `<Boolean>`

Continue if an error is encountered. Default is $true.

-------------------------- EXAMPLE 1 --------------------------

```powershell
PS C:\>Execute-ProcessAsUser -UserName 'CONTOSO\User' -Path "$PSHOME\powershell.exe" -Parameters "-Command & { & `"C:\Test\Script.ps1`"; Exit `$LastExitCode }" -Wait
```

Execute process under a user account by specifying a username under
which to execute it.

-------------------------- EXAMPLE 2 --------------------------

```powershell
PS C:\>Execute-ProcessAsUser -Path "$PSHOME\powershell.exe" -Parameters "-Command & { & `"C:\Test\Script.ps1`"; Exit `$LastExitCode }" -Wait
```

Execute process under a user account by using the default active logged
in user that was detected when the toolkit was launched.
