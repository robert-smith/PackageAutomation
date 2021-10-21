Resolve-Error
=============

SYNOPSIS
--------

Enumerate error record details.

SYNTAX
------

```powershell
Resolve-Error [[-ErrorRecord] <Array>] [[-Property] <String[]>] [[-GetErrorRecord]] [[-GetErrorInvocation]] [[-GetErrorException]] [[-GetErrorInnerException]] [<CommonParameters>]
```

DESCRIPTION
-----------

Enumerate an error record, or a collection of error record, properties.
By default, the details for the last error will be enumerated.

PARAMETERS
----------

### -ErrorRecord

**Type**: `<Array>`

The error record to resolve. The default error record is the latest one:
$global:Error[0]. This parameter will also accept an array of error
records.

### -Property

**Type**: `<String[]>`

The list of properties to display from the error record. Use "*" to
display all properties.

Default list of error properties is: Message, FullyQualifiedErrorId,
ScriptStackTrace, PositionMessage, InnerException

### -GetErrorRecord

**Type**: `[<SwitchParameter>]`

Get error record details as represented by $_.

### -GetErrorInvocation

**Type**: `[<SwitchParameter>]`

Get error record invocation information as represented by
$_.InvocationInfo.

### -GetErrorException

**Type**: `[<SwitchParameter>]`

Get error record exception details as represented by $_.Exception.

### -GetErrorInnerException

**Type**: `[<SwitchParameter>]`

Get error record inner exception details as represented by
$_.Exception.InnerException. Will retrieve all inner exceptions if
there is more than one.

-------------------------- EXAMPLE 1 --------------------------

```powershell
PS C:\>Resolve-Error
```

-------------------------- EXAMPLE 2 --------------------------

```powershell
PS C:\>Resolve-Error -Property *
```

-------------------------- EXAMPLE 3 --------------------------

```powershell
PS C:\>Resolve-Error -Property InnerException
```

-------------------------- EXAMPLE 4 --------------------------

```powershell
PS C:\>Resolve-Error -GetErrorInvocation:$false
```
