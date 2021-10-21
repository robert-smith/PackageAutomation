function Update-TaskSequence {
    [CmdletBinding()]
    param (
        [string]$ApplicationName,
        [string[]]$TaskSequence
    )

    $Results = foreach ($TS in $TaskSequence) {
        $InstallStep = Get-CMTSStepInstallApplication -TaskSequenceName $TS
        [System.Collections.ArrayList]$Apps = $InstallStep.AppInfo.DisplayName
        if ($ApplicationName -in $Apps) {
            $Status = 'OK'
            $Color = $ANSI.Green
        }
        else {
            # Drop the version number to get the base app name
            $BaseName = $ApplicationName -replace '\s[^\s]+$'
            $Remove = $Apps.Where{$_ -like "$BaseName*"}
            $Apps.Remove("$Remove")
            $Apps.Add("$ApplicationName") > $null
            $Applications = foreach ($App in $Apps) {
                Get-CMApplication -Name $App
            }
            Set-CMTSStepInstallApplication -TaskSequenceName $TS -Application $Applications
            $Status = 'Success'
            $Color = $ANSI.Yellow
        }
        Write-Host -Object ('    - ' + $Color + $Status + ': ' + $ANSI.Reset + $TS)
        Write-Output -InputObject ($Status + ': ' + $TS)
    }

    return $Results
}