<#

.SYNOPSIS
The purpose of this function is to take errors and output a concise error message that
includes just the error message, command, and what line it failed at.

#>

function Write-Fail {

    $Cmd = $_.InvocationInfo.InvocationName
    $Msg = $_.Exception.Message
    $Line = $_.InvocationInfo.ScriptLineNumber
    $Output = "($Cmd at line $Line) $Msg"
    
    $Phase = Get-Phase
    $Phase.Status = "Failed: $Output"
    Write-Host -Object ($ANSI.Red + 'Failed: ' + $ANSI.Reset + $Output)
}