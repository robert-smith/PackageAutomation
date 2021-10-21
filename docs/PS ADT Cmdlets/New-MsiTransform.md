New-MsiTransform
================

SYNOPSIS
--------

Create a transform file for an MSI database.

SYNTAX
------

```powershell
New-MsiTransform [-MsiPath] <String> [[-ApplyTransformPath] <String>] [[-NewTransformPath] <String>] [-TransformProperties] <Hashtable> [[-ContinueOnError] <Boolean>] [<CommonParameters>]
```

DESCRIPTION
-----------

Create a transform file for an MSI database and create/modify properties
in the Properties table.

PARAMETERS
----------

### -MsiPath

**Type**: `<String>`

Specify the path to an MSI file.

### -ApplyTransformPath

**Type**: `<String>`

Specify the path to a transform which should be applied to the MSI
database before any new properties are created or modified.

### -NewTransformPath

**Type**: `<String>`

Specify the path where the new transform file with the desired
properties will be created. If a transform file of the same name already
exists, it will be deleted before a new one is

created.

Default is: a) If -ApplyTransformPath was specified but not
-NewTransformPath, then <ApplyTransformPath>.new.mst

b) If only -MsiPath was specified, then <MsiPath>.mst

### -TransformProperties

**Type**: `<Hashtable>`

Hashtable which contains calls to Set-MsiProperty for configuring the
desired properties which should be included in new transform file.

Example hashtable: [hashtable]$TransformProperties = @{ 'ALLUSERS' =
'1' }

### -ContinueOnError

**Type**: `<Boolean>`

Continue if an error is encountered. Default is: $true.

-------------------------- EXAMPLE 1 --------------------------

```powershell
PS C:\>[hashtable]$TransformProperties = {
```

'ALLUSERS' = '1'

'AgreeToLicense' = 'Yes'

'REBOOT' = 'ReallySuppress'

'RebootYesNo' = 'No'

'ROOTDRIVE' = 'C:'

}

New-MsiTransform -MsiPath 'C:\Temp\PSADTInstall.msi'
-TransformProperties $TransformProperties
