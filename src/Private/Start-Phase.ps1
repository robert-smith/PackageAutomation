<#

.SYNOPSIS
The purpose of this function is to output status messages so that all their results
are aligned in the console. This is just to make it easier to read the results of the
automation job.

#>

function Start-Phase {
    [CmdletBinding()]
    param (
        [string]$Phase
    )

    $Longest = ($Results.Phases.Description | Measure-Object -Maximum -Property Length).Maximum
    $Message = $Results.Phases.Where{$_.Name -eq $Phase}.Description

    # Make the number of dots after every message the same for easier readability.
    $Dots = '.' * (($Longest + 3) - $Message.Length)
    $Output = '  + ' + $Message + $Dots

    foreach ($item in $Script:Results.Phases) {
        if ($item.Name -eq $Phase) {
            $item.Status = 'Running'
            break
        }
    }
    Write-Host -Object $Output -NoNewLine
}
