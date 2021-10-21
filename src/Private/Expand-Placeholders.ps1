<#

.SYNOPSIS
The purpose of this function is to replace all placeholders in an object with their
desired values. This is done using a hashtable that contains the placeholder text
for the key and its desired value for the value. Each item (key) in the hashtable
will attempt to be found in the supplied object and replaced with the key's value.

#>

function Expand-Placeholders {
    [CmdletBinding()]
    param (
        $InputObject,
        [hashtable]$Legend = $Script:ReplaceLegend
    )

    begin {
    }

    process {
        foreach ($item in $Legend.GetEnumerator()) {
            $InputObject = $InputObject -replace [regex]::Escape($item.Name), $item.Value
        }
    }

    end {
        # Convert the object back into a scriptblock since it became a string after running -replace
        return [scriptblock]::Create($InputObject)
    }
}