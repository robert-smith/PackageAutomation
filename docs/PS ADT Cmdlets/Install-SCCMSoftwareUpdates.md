Install-SCCMSoftwareUpdates
===========================

SYNOPSIS
--------

Scans for outstanding SCCM updates to be installed and installs the
pending updates.

SYNTAX
------

```powershell
Install-SCCMSoftwareUpdates [[-SoftwareUpdatesScanWaitInSeconds] <Int32>] [[-WaitForPendingUpdatesTimeout] <TimeSpan>] [[-ContinueOnError] <Boolean>] [<CommonParameters>]
```

DESCRIPTION
-----------

Scans for outstanding SCCM updates to be installed and installs the
pending updates.

Only compatible with SCCM 2012 Client or higher. This function can take
several minutes to run.

PARAMETERS
----------

### -SoftwareUpdatesScanWaitInSeconds

**Type**: `<Int32>`

The amount of time to wait in seconds for the software updates scan to
complete. Default is: 180 seconds.

### -WaitForPendingUpdatesTimeout

**Type**: `<TimeSpan>`

The amount of time to wait for missing and pending updates to install
before exiting the function. Default is: 45 minutes.

### -ContinueOnError

**Type**: `<Boolean>`

Continue if an error is encountered. Default is: $true.

-------------------------- EXAMPLE 1 --------------------------

```powershell
PS C:\>Install-SCCMSoftwareUpdates
```
