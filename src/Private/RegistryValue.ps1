<#

.SYNOPSIS
A wrapper for the New-CMDetectionClauseRegistryKeyValue command to make it like a DSL.

#>

function RegistryValue {
    [CmdletBinding()]
    param (
        [scriptblock]$ScriptBlock
    )

    $Splat = Convert-ScriptblockToHashtable -ScriptBlock $ScriptBlock
    # The Value parameter on New-CMDetectionClauseRegistryValue is a switch. If defined in
    # Application, it will get expanded when converting the scriptblock to a hashtable. The
    # expanded value is not accepted by switch parameters, so to avoid getting overly
    # complicated, we'll just define it here since it's required either way. This is A LOT
    # of commenting for a line with 20 characters...
    $Splat.Value = $true
    New-CMDetectionClauseRegistryKeyValue @Splat
}