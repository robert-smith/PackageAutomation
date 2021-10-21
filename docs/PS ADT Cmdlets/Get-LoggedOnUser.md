Get-LoggedOnUser
================

SYNOPSIS
--------

Get session details for all local and RDP logged on users.

SYNTAX
------

```powershell
Get-LoggedOnUser [<CommonParameters>]
```

DESCRIPTION
-----------

Get session details for all local and RDP logged on users using Win32
APIs. Get the following session details:

NTAccount, SID, UserName, DomainName, SessionId, SessionName,
ConnectState, IsCurrentSession, IsConsoleSession, IsUserSession,
IsActiveUserSession

IsRdpSession, IsLocalAdmin, LogonTime, IdleTime, DisconnectTime,
ClientName, ClientProtocolType, ClientDirectory, ClientBuildNumber

PARAMETERS
----------
-------------------------- EXAMPLE 1 --------------------------

```powershell
PS C:\>Get-LoggedOnUser
```
