Test-NetworkConnection
======================

SYNOPSIS
--------

Tests for an active local network connection, excluding wireless and
virtual network adapters.

SYNTAX
------

```powershell
Test-NetworkConnection [<CommonParameters>]
```

DESCRIPTION
-----------

Tests for an active local network connection, excluding wireless and
virtual network adapters, by querying the Win32_NetworkAdapter WMI
class.

PARAMETERS
----------

-------------------------- EXAMPLE 1 --------------------------

```powershell
PS C:\>Test-NetworkConnection
```
