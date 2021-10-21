function Set-Supersedence {
    param (
        [string]$Name,
        [bool]$Uninstall
    )

    begin {
        $Results = [pscustomobject]@{
            Status = ''
            Details = ''
        }
        # Get last version of app
        $Apps = Get-OrderedAppVersion -Name $Name
        $Current = $Apps | Select-Object -First 1
        $OldApp = $Apps | Select-Object -Skip 1 -First 1
        # Get the new deployment type again because we modified it in the last step which means it's no longer the most recent revision of that object
        $NewDT = Get-CMDeploymentType -ApplicationName $Current.LocalizedDisplayName
        $Supersedence = Get-Supersedence -Application $Current
    }

    process {
        if ($OldApp) {
            $OldDT = Get-CMDeploymentType -ApplicationName $OldApp.LocalizedDisplayName
            $LogicalName = $OldDT.CI_UniqueID.split('/')[1]
        }
        if (-not $OldApp) {
            $Results.Status = 'OK'
            $Results.Details = 'No older versions found'
        }
        elseif ($Supersedence.LogicalName -eq $LogicalName) {
            if ($Supersedence.Changeable -eq $Uninstall) {
                $Results.Status = 'OK'
            }
            else {
                $SetSupersede = @{
                    SupersedingDeploymentType = $OldDT
                    InputObject = $NewDT
                    IsUninstall = $Uninstall
                }  
                Set-CMDeploymentTypeSupersedence @SetSupersede
                $Results.Status = 'Success'
                $Results.Details = "Uninstall mode changed to $($Uninstall)"
            }
        }
        else {
            $NewSupersede = @{
                SupersedingDeploymentType = $NewDT
                SupersededDeploymentType = $OldDT
                IsUninstall = $Uninstall
            }
            Add-CMDeploymentTypeSupersedence @NewSupersede > $null
            $Results.Status = 'Success' 
            $Results.Details = "Uninstall mode set to $($Uninstall)"
        }
    }

    end {
        return $Results
    }

}