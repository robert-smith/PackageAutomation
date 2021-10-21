function Deploy {
    [CmdletBinding()]
    param (
        [scriptblock]$ScriptBlock
    )

    $DeployExpanded = Expand-Placeholders -InputObject $ScriptBlock -Legend $ReplaceLegend
    $Splat = Convert-ScriptBlockToHashtable -ScriptBlock $DeployExpanded
    # Form the name of the SCCM application
    $Splat.Name = $ReplaceLegend.'%%APPNAME%%' + ' ' + $ReplaceLegend.'%%VERSION%%'
    # If Time and Action are null, give them defaults
    switch ($null) {
        $Splat.TimeBaseOn {$Splat.TimeBaseOn = 'LocalTime'}
        $Splat.DeployAction {$Splat.DeployAction = 'Install'}
    }
    
    $Details = $Splat.DeployAction + ' ' + $Splat.DeployPurpose + ' -> ' + $Splat.CollectionName
    if (Get-CMApplicationDeployment -Name $Splat.Name -CollectionName $Splat.CollectionName) {
        $Status = 'OK'
        $Color = $ANSI.Green
    }
    else {
        New-CMApplicationDeployment @Splat -WarningAction SilentlyContinue > $null
        $Status = 'Success'
        $Color = $ANSI.Yellow
    }
    Write-Host -Object ('    - ' + $Color + $Status + ': ' + $ANSI.Reset + $Details)

    # Return the status of the deployment so that it can be added to the Deploy phase details
    return $Status + ': ' + $Details
}