function Remove-OldAppVersion {
    [CmdletBinding()]
    param (
        [string]$Name,
        [int]$Keep
    )

    $Version = Get-OrderedAppVersion -Name $Name
    $Remove = $Version | Select-Object -Skip $Keep
    # Drop down 1 line if there are versions to remove
    if ($Remove) {
        Write-Host ''
    }
    $Results = foreach ($App in $Remove) {
        $AppName = $App.LocalizedDisplayName
        Get-CMApplicationDeployment -Name $AppName | Remove-CMApplicationDeployment -Force
        Get-CMApplication -Name $AppName | Remove-CMApplication -Force
        $Status = 'Success'
        $Color = $ANSI.Yellow
        Write-Host -Object ('    - ' + $Color + $Status + ': ' + $ANSI.Reset + $AppName)
        Write-Output -InputObject ($Status + ": $AppName")
    }

    return $Results
}