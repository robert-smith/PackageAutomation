<#

.SYNOPSIS
The purpose of this function is to take a scriptblock that is layed out
like a hashtable and convert it to one. This is mainly used to make the
DSL syntax usable with commands.

#>

function Convert-ScriptblockToHashtable {
    [CmdletBinding()]
    param (
        [scriptblock]$ScriptBlock
    )
    
    begin {

    }

    process {
        $HashtableString = "[ordered]@{$($ScriptBlock.ToString())}"
        $NewScriptBlock = [scriptblock]::Create($HashtableString)

    }

    end {
        return & $NewScriptBlock
    }
}