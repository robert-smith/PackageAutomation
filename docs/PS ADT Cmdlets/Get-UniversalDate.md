Get-UniversalDate
=================

SYNOPSIS
--------

Returns the date/time for the local culture in a universal sortable date
time pattern.

SYNTAX
------

```powershell
Get-UniversalDate [[-DateTime] <String>] [[-ContinueOnError] <Boolean>] [<CommonParameters>]
```

DESCRIPTION
-----------

Converts the current datetime or a datetime string for the current
culture into a universal sortable date time pattern, e.g. 2013-08-22
11:51:52Z

PARAMETERS
----------

### -DateTime

**Type**: `<String>`

Specify the DateTime in the current culture.

### -ContinueOnError

**Type**: `<Boolean>`

Continue if an error is encountered. Default: $false.

-------------------------- EXAMPLE 1 --------------------------

```powershell
PS C:\>Get-UniversalDate
```

Returns the current date in a universal sortable date time pattern.

-------------------------- EXAMPLE 2 --------------------------

```powershell
PS C:\>Get-UniversalDate -DateTime '25/08/2013'
```

Returns the date for the current culture in a universal sortable date
time pattern.
