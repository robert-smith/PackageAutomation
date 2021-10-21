function Send-ResultEmail {
    [CmdletBinding()]
    param (
        $Results,
        [switch]$Concise,
        [string]$SuccessAddress,
        [string]$FailureAddress,
        [string]$From,
        [string]$SmtpServer,
        [int]$Port = 25,
        [switch]$UseSsl,
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]$Credential
    )

    begin {
        $CSSFile = (Split-Path -Path $PSScriptRoot -Parent) + '\Config\email.css'
        $CSS = Get-Content -Path $CSSFile -Raw
    }

    process {
        $HTML = foreach ($app in $Results) {
            if ($app.Phases.Status -match '^Failed') {
                $ResultType = 'Failed'
                $To = $FailureAddress
            }
            elseif ($app.Phases.Status -match '^Success') {
                $ResultType = 'Success'
                $To = $SuccessAddress
            }
            else {
                # Skip to the next app
                continue
            }

            # Set concise filter
            if ($Concise) {
                $Filter = "^(Success|Failed)"
            }
            else {
                $Filter = '^.*'
            }

            $Header = @(
                '<table>'
                '<caption><h3>' + $app.Name + '</h3></caption>'
                '<tr><th>Phase</th><th>Status</th></tr>'
            )
            $Body = foreach ($phase in $app.Phases.Where{$_.Status -match $Filter}) {
                $Count = $phase.Status.Count
                '<tr>'
                "<td rowspan=`"$Count`"><b>" + $phase.Description + '</b></td>'
                $tds = foreach ($item in $phase.Status) {
                    $td = switch -Regex ($item) {
                    'Failed' {'<td id="Fail">'; break}
                    'Success' {'<td id="Success">'; break}
                    default {'<td>'}
                    }
                    $td + $item + '</td>'
                }
                $tds -join '</tr><tr>'
                '</tr>'
            }
            $End = @(
                '</table>'
                '</br>'
            )
            Write-Output -InputObject ($Header + $Body + $End)
        }
        if ($null -ne $HTML) {
            $Style = '<style>' + $CSS + '</style>'
            $Body = $Style + $HTML
            #

            $Splat = @{
                Body = $Body
                From = $From
                Subject = '[' + $ResultType + '] ' + "Package Automation Report"
                To = $To
                SmtpServer = $SmtpServer
                Port = $Port
                UseSsl = $UseSsl
                BodyAsHTML = $true
            }
           
            # Add credential property only if credentials specified. Send-MailMessage does not like null credential objects.
            if ($Credential.UserName) {
                $Splat.Credential = $Credential
            }

            Send-MailMessage @Splat
        }
    }

    end {}
    
}