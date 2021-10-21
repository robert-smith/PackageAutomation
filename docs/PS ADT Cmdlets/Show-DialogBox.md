Show-DialogBox
==============

SYNOPSIS
--------

Display a custom dialog box with optional title, buttons, icon and
timeout.

Show-InstallationPrompt is recommended over this function as it provides
more customization and uses consistent branding with the other UI
components.

SYNTAX
------

```powershell
Show-DialogBox [-Text] <String> [-Title <String>] [-Buttons <String>] [-DefaultButton <String>] [-Icon <String>] [-Timeout <String>] [-TopMost <Boolean>] [<CommonParameters>]
```

DESCRIPTION
-----------

Display a custom dialog box with optional title, buttons, icon and
timeout. The default button is "OK", the default Icon is "None", and the
default Timeout is none.

PARAMETERS
----------

### -Text

**Type**: `<String>`

Text in the message dialog box

### -Title

**Type**: `<String>`

Title of the message dialog box

### -Buttons

**Type**: `<String>`

Buttons to be included on the dialog box. Options: OK, OKCancel,
AbortRetryIgnore, YesNoCancel, YesNo, RetryCancel,
CancelTryAgainContinue. Default: OK.

### -DefaultButton

**Type**: `<String>`

The Default button that is selected. Options: First, Second, Third.
Default: First.

### -Icon

**Type**: `<String>`

Icon to display on the dialog box. Options: None, Stop, Question,
Exclamation, Information. Default: None.

### -Timeout

**Type**: `<String>`

Timeout period in seconds before automatically closing the dialog box
with the return message "Timeout". Default: UI timeout value set in the
config XML file.

### -TopMost

**Type**: `<Boolean>`

Specifies whether the message box is a system modal message box and
appears in a topmost window. Default: $true.

-------------------------- EXAMPLE 1 --------------------------

```powershell
PS C:\>Show-DialogBox -Title 'Installed Complete' -Text 'Installation has completed. Please click OK and restart your computer.' -Icon 'Information'
```

-------------------------- EXAMPLE 2 --------------------------

```powershell
PS C:\>Show-DialogBox -Title 'Installation Notice' -Text 'Installation will take approximately 30 minutes. Do you wish to proceed?' -Buttons 'OKCancel' -DefaultButton 'Second' -Icon
```

'Exclamation' -Timeout 600 -Topmost $false
