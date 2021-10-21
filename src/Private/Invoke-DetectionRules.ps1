function Invoke-DetectionRules {
    [CmdletBinding()]
    param (
        [scriptblock]$ScriptBlock
    )
    Start-Phase -Phase DetectionRules
    $DetectExpanded = Expand-Placeholders -InputObject $DetectionRules -Legend $ReplaceLegend
    $Detect = & $DetectExpanded
    Complete-Phase -Status Done
    return $Detect
}