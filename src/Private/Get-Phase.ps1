<#
Finds the phase that has a status of 'Running'.
#>
function Get-Phase {
    [CmdletBinding()]
    param()
    
    foreach ($item in $Script:Results.Phases) {
        if ($item.Status -eq 'Running') {
            return $item
        }
    }
}