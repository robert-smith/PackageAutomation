Stop-ServiceAndDependencies
===========================

SYNOPSIS
--------

Stop Windows service and its dependencies.

SYNTAX
------

```powershell
Stop-ServiceAndDependencies [-Name] <String> [[-ComputerName] <String>] [-SkipServiceExistsTest] [-SkipDependentServices] [[-PendingStatusWait] <TimeSpan>] [-PassThru] [[-ContinueOnError] <Boolean>] [<CommonParameters>]
```

DESCRIPTION
-----------

Stop Windows service and its dependencies.

PARAMETERS
----------

### -Name

**Type**: `<String>`

Specify the name of the service.

### -ComputerName

**Type**: `<String>`

Specify the name of the computer. Default is: the local computer.

### -SkipServiceExistsTest

**Type**: `[<SwitchParameter>]`

Choose to skip the test to check whether or not the service exists if it
was already done outside of this function.

### -SkipDependentServices

**Type**: `[<SwitchParameter>]`

Choose to skip checking for and stopping dependent services. Default is:
$false.

### -PendingStatusWait

**Type**: `<TimeSpan>`

The amount of time to wait for a service to get out of a pending state
before continuing. Default is 60 seconds.

### -PassThru

**Type**: `[<SwitchParameter>]`

Return the System.ServiceProcess.ServiceController service object.

### -ContinueOnError

**Type**: `<Boolean>`

Continue if an error is encountered. Default is: $true.

-------------------------- EXAMPLE 1 --------------------------

```powershell
PS C:\>Stop-ServiceAndDependencies -Name 'wuauserv'
```
