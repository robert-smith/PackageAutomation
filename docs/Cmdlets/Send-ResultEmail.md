---
external help file: PackageAutomation-help.xml
Module Name: PackageAutomation
online version:
schema: 2.0.0
---

# Send-ResultEmail

## SYNOPSIS
Sends an email report with HTML tables listing the results from each job.

## SYNTAX

```
Send-ResultEmail [[-Results] <Object>] [[-ResultType] <String>] [[-To] <String>] [[-From] <String>]
 [[-SmtpServer] <String>] [<CommonParameters>]
```

## DESCRIPTION
Sends an email report with HTML tables listing the results from each job. This will accept one or more results from the `Publish-Application` command.

## EXAMPLES

### Example 1
```powershell
PS C:\> $Results = .\package.ps1
PS C:\> Send-ResultEmail -Results $Results -ResultType Success -To 'success@contoso.com' -From 'packageautomation@contoso.com' -SmtpServer 'mail.consoto.com'
```

Sends any success results to **success@contoso.com**.

### Example 2
```powershell
PS C:\> $Results = .\package.ps1
PS C:\> Send-ResultEmail -Results $Results -ResultType Failed -To 'fails@contoso.com' -From 'packageautomation@contoso.com' -SmtpServer 'mail.consoto.com'
```

Sends any failures results to **fails@contoso.com**.

## PARAMETERS

### -From
The address that the email should appear to come from.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ResultType
The type of results to send in the email.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Success, Failed

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Results
The results that `Publish-Application` (`Application`) outputs. This will accept multiple results.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SmtpServer
The SMTP server address.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -To
The email address that should receive the report.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
