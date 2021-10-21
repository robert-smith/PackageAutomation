<#

.SYNOPSIS
A wrapper for the New-CMDetectionClauseFile command to make it like a DSL.

#>

function File {
    [CmdletBinding()]
    param (
        [scriptblock]$ScriptBlock
    )

    $Splat = Convert-ScriptblockToHashtable -ScriptBlock $ScriptBlock
    # The Existence and Value parameters on New-CMDetectionClauseRegistryValue are switchs.
    # If defined in Application, it will get expanded when converting the scriptblock to a
    # hashtable. The expanded value is not accepted by switch parameters, so to avoid getting
    # overly complicated, we'll just define it here since it's required either way. This is
    # A LOT of commenting for a line with 24 characters...
    if ($Splat.ExpectedValue) {
        $Splat.Value = $true
    }
    else {
        $Splat.Existence = $true
    }
    
    New-CMDetectionClauseFile @Splat
}