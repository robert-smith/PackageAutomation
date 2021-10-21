Execute-MSP
===========

SYNOPSIS
--------

Reads SummaryInfo targeted product codes in MSP file and determines if
the MSP file applies to any installed products

If a valid installed product is found, triggers the Execute-MSI function
to patch the installation.

SYNTAX
------

```powershell
Execute-MSP [-Path] <String> [<CommonParameters>]
```

DESCRIPTION
-----------

PARAMETERS
----------

### -Path

**Type**: `<String>`

-------------------------- EXAMPLE 1 --------------------------

```powershell
PS C:\>Execute-MSP -Path 'Adobe_Reader_11.0.3_EN.msp'
```
