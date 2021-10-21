Get-InstalledApplication
========================

SYNOPSIS
--------

Retrieves information about installed applications.

SYNTAX
------

```powershell
Get-InstalledApplication [[-Name] <String[]>] [-Exact] [-WildCard] [-RegEx] [[-ProductCode] <String>] [-IncludeUpdatesAndHotfixes] [<CommonParameters>]
```

DESCRIPTION
-----------

Retrieves information about installed applications by querying the
registry. You can specify an application name, a product code, or both.

Returns information about application publisher, name & version, product
code, uninstall string, install source, location, date, and application
architecture.

PARAMETERS
----------

### -Name

**Type**: `<String[]>`

The name of the application to retrieve information for. Performs a
contains match on the application display name by default.

### -Exact

**Type**: `[<SwitchParameter>]`

Specifies that the named application must be matched using the exact
name.

### -WildCard

**Type**: `[<SwitchParameter>]`

Specifies that the named application must be matched using a wildcard
search.

### -RegEx

**Type**: `[<SwitchParameter>]`

Specifies that the named application must be matched using a regular
expression search.

### -ProductCode

**Type**: `<String>`

The product code of the application to retrieve information for.

### -IncludeUpdatesAndHotfixes

**Type**: `[<SwitchParameter>]`

Include matches against updates and hotfixes in results.

-------------------------- EXAMPLE 1 --------------------------

```powershell
PS C:\>Get-InstalledApplication -Name 'Adobe Flash'
```

-------------------------- EXAMPLE 2 --------------------------

```powershell
PS C:\>Get-InstalledApplication -ProductCode '{1AD147D0-BE0E-3D6C-AC11-64F6DC4163F1}'
```
