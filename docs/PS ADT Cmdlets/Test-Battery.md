Test-Battery
============

SYNOPSIS
--------

Tests whether the local machine is running on AC power or not.

SYNTAX
------

```powershell
Test-Battery [-PassThru] [<CommonParameters>]
```

DESCRIPTION
-----------

Tests whether the local machine is running on AC power and returns
true/false. For detailed information, use -PassThru option.

PARAMETERS
----------

### -PassThru

**Type**: `[<SwitchParameter>]`

Outputs a hashtable containing the following properties:

IsLaptop, IsUsingACPower, ACPowerLineStatus, BatteryChargeStatus,
BatteryLifePercent, BatteryLifeRemaining, BatteryFullLifetime

-------------------------- EXAMPLE 1 --------------------------

```powershell
PS C:\>Test-Battery
```

-------------------------- EXAMPLE 2 --------------------------

```powershell
PS C:\>(Test-Battery -PassThru).IsLaptop
```

Determines if the current system is a laptop or not.
