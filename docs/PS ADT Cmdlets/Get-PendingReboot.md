Get-PendingReboot
=================

SYNOPSIS
--------

Get the pending reboot status on a local computer.

SYNTAX
------

```powershell
Get-PendingReboot [<CommonParameters>]
```

DESCRIPTION
-----------

Check WMI and the registry to determine if the system has a pending
reboot operation from any of the following:

a) Component Based Servicing (Vista, Windows 2008)

b) Windows Update / Auto Update (XP, Windows 2003 / 2008)

c) SCCM 2012 Clients (DetermineIfRebootPending WMI method)

d) App-V Pending Tasks (global based Appv 5.0 SP2)

e) Pending File Rename Operations (XP, Windows 2003 / 2008)

PARAMETERS
----------

-------------------------- EXAMPLE 1 --------------------------

```powershell
PS C:\>Get-PendingReboot
```

Returns custom object with following properties:

ComputerName, LastBootUpTime, IsSystemRebootPending,
IsCBServicingRebootPending, IsWindowsUpdateRebootPending,
IsSCCMClientRebootPending, IsFileRenameRebootPending,

PendingFileRenameOperations, ErrorMsg

*Notes: ErrorMsg only contains something if an error occurred

-------------------------- EXAMPLE 2 --------------------------

```powershell
PS C:\>(Get-PendingReboot).IsSystemRebootPending
```

Returns boolean value determining whether or not there is a pending
reboot operation.
