function Remove-OldDeployment {
    [CmdletBinding()]
    param (
        [string]$Name
    )

    $Versions = Get-OrderedAppVersion -Name $Name
    if ($Versions.Count -gt 1) {
        $Previous = $Versions[1]
        $PrevDeploys = Get-CMApplicationDeployment -Name $Previous.LocalizedDisplayName
    }
    if ($PrevDeploys) {
        foreach ($PrevDeploy in $PrevDeploys) {
            Remove-CMApplicationDeployment -InputObject $PrevDeploy -Force
        }
        return [PSCustomObject]@{
            Status = 'Success'
            Details = "Removed $($PrevDeploys.Count) deployments."
        }
    }
    else {
        return [PSCustomObject]@{
            Status = 'OK'
        }
    }
}