Invoke-RegisterOrUnregisterDLL
==============================

SYNOPSIS
--------

Register or unregister a DLL file.

SYNTAX
------

```powershell
Invoke-RegisterOrUnregisterDLL [-FilePath] <String> [[-DLLAction] <String>] [[-ContinueOnError] <Boolean>] [<CommonParameters>]
```

DESCRIPTION
-----------

Register or unregister a DLL file using regsvr32.exe. Function can be
invoked using alias: 'Register-DLL' or 'Unregister-DLL'.

PARAMETERS
----------

### -FilePath

**Type**: `<String>`

Path to the DLL file.

### -DLLAction

**Type**: `<String>`

Specify whether to register or unregister the DLL. Optional if function
is invoked using 'Register-DLL' or 'Unregister-DLL' alias.

### -ContinueOnError

**Type**: `<Boolean>`

Continue if an error is encountered. Default is: $true.

-------------------------- EXAMPLE 1 --------------------------

```powershell
PS C:\>Register-DLL -FilePath "C:\Test\DcTLSFileToDMSComp.dll"
```

Register DLL file using the "Register-DLL" alias for this function

-------------------------- EXAMPLE 2 --------------------------

```powershell
PS C:\>UnRegister-DLL -FilePath "C:\Test\DcTLSFileToDMSComp.dll"
```

Unregister DLL file using the "Unregister-DLL" alias for this function

-------------------------- EXAMPLE 3 --------------------------

```powershell
PS C:\>Invoke-RegisterOrUnregisterDLL -FilePath "C:\Test\DcTLSFileToDMSComp.dll" -DLLAction 'Register'
```

Register DLL file using the actual name of this function
