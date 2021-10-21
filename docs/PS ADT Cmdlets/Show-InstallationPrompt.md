Show-InstallationPrompt
=======================

SYNOPSIS
--------

Displays a custom installation prompt with the toolkit branding and
optional buttons.

SYNTAX
------

```powershell
Show-InstallationPrompt [[-Title] <String>] [[-Message] <String>] [[-MessageAlignment] <String>] [[-ButtonRightText] <String>] [[-ButtonLeftText] <String>] [[-ButtonMiddleText] <String>] [[-Icon] <String>] [-NoWait] [-PersistPrompt] [[-MinimizeWindows] <Boolean>] [[-Timeout] <Int32>] [[-ExitOnTimeout] <Boolean>] [<CommonParameters>]
```

DESCRIPTION
-----------

Any combination of Left, Middle or Right buttons can be displayed. The
return value of the button clicked by the user is the button text
specified.

PARAMETERS
----------

### -Title

**Type**: `<String>`

Title of the prompt. Default: the application installation name.

### -Message

**Type**: `<String>`

Message text to be included in the prompt

### -MessageAlignment

**Type**: `<String>`

Alignment of the message text. Options: Left, Center, Right. Default:
Center.

### -ButtonRightText

**Type**: `<String>`

Show a button on the right of the prompt with the specified text

### -ButtonLeftText

**Type**: `<String>`

Show a button on the left of the prompt with the specified text

### -ButtonMiddleText

**Type**: `<String>`

Show a button in the middle of the prompt with the specified text

### -Icon

**Type**: `<String>`

Show a system icon in the prompt. Options: Application, Asterisk, Error,
Exclamation, Hand, Information, None, Question, Shield, Warning,
WinLogo. Default: None.

### -NoWait

**Type**: `[<SwitchParameter>]`

Specifies whether to show the prompt asynchronously (i.e. allow the
script to continue without waiting for a response). Default: $false.

### -PersistPrompt

**Type**: `[<SwitchParameter>]`

Specify whether to make the prompt persist in the center of the screen
every 10 seconds. The user will have no option but to respond to the
prompt - resistance is futile!

### -MinimizeWindows

**Type**: `<Boolean>`

Specifies whether to minimize other windows when displaying prompt.
Default: $false.

### -Timeout

**Type**: `<Int32>`

Specifies the time period in seconds after which the prompt should
timeout. Default: UI timeout value set in the config XML file.

### -ExitOnTimeout

**Type**: `<Boolean>`

Specifies whether to exit the script if the UI times out. Default:
$true.

-------------------------- EXAMPLE 1 --------------------------

```powershell
PS C:\>Show-InstallationPrompt -Message 'Do you want to proceed with the installation?' -ButtonRightText 'Yes' -ButtonLeftText 'No'
```

-------------------------- EXAMPLE 2 --------------------------

```powershell
PS C:\>Show-InstallationPrompt -Title 'Funny Prompt' -Message 'How are you feeling today?' -ButtonRightText 'Good' -ButtonLeftText 'Bad' -ButtonMiddleText 'Indifferent'
```

-------------------------- EXAMPLE 3 --------------------------

```powershell
PS C:\>Show-InstallationPrompt -Message 'You can customize text to appear at the end of an install, or remove it completely for unattended installations.' -Icon Information -NoWait
```
