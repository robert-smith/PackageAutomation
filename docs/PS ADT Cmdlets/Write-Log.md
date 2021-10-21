Write-Log
=========

SYNOPSIS
--------

Write messages to a log file in CMTrace.exe compatible format or Legacy
text file format.

SYNTAX
------

```powershell
Write-Log [-Message] <String[]> [[-Severity] <Int16>] [[-Source] <String>] [[-ScriptSection] <String>] [[-LogType] <String>] [[-LogFileDirectory] <String>] [[-LogFileName] <String>] [[-MaxLogFileSizeMB] <Decimal>] [[-WriteHost] <Boolean>] [[-ContinueOnError] <Boolean>] [[-PassThru]] [[-DebugMessage]] [[-LogDebugMessage] <Boolean>] [<CommonParameters>]
```

DESCRIPTION
-----------

Write messages to a log file in CMTrace.exe compatible format or Legacy
text file format and optionally display in the console.

PARAMETERS
----------

### -Message

**Type**: `<String[]>`

The message to write to the log file or output to the console.

### -Severity

**Type**: `<Int16>`

Defines message type. When writing to console or CMTrace.exe log format,
it allows highlighting of message type.

Options: 1 = Information (default), 2 = Warning (highlighted in yellow),
3 = Error (highlighted in red)

### -Source

**Type**: `<String>`

The source of the message being logged.

### -ScriptSection

**Type**: `<String>`

The heading for the portion of the script that is being executed.
Default is: $script:installPhase.

### -LogType

**Type**: `<String>`

Choose whether to write a CMTrace.exe compatible log file or a Legacy
text log file.

### -LogFileDirectory

**Type**: `<String>`

Set the directory where the log file will be saved.

### -LogFileName

**Type**: `<String>`

Set the name of the log file.

### -MaxLogFileSizeMB

**Type**: `<Decimal>`

Maximum file size limit for log file in megabytes (MB). Default is 10
MB.

### -WriteHost

**Type**: `<Boolean>`

Write the log message to the console.

### -ContinueOnError

**Type**: `<Boolean>`

Suppress writing log message to console on failure to write message to
log file. Default is: $true.

### -PassThru

**Type**: `[<SwitchParameter>]`

Return the message that was passed to the function

### -DebugMessage

**Type**: `[<SwitchParameter>]`

Specifies that the message is a debug message. Debug messages only get
logged if -LogDebugMessage is set to $true.

### -LogDebugMessage

**Type**: `<Boolean>`

Debug messages only get logged if this parameter is set to $true in the
config XML file.

-------------------------- EXAMPLE 1 --------------------------

```powershell
PS C:\>Write-Log -Message "Installing patch MS15-031" -Source 'Add-Patch' -LogType 'CMTrace'
```

-------------------------- EXAMPLE 2 --------------------------

```powershell
PS C:\>Write-Log -Message "Script is running on Windows 8" -Source 'Test-ValidOS' -LogType 'Legacy'
```
