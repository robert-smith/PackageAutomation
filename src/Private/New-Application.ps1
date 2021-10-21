<#

The purpose of this function is to tie all the commands related to creating
SCCM applications together into a single command. This command makes the
following assumptions when run:

1. An icon.png file will be located in the directory above $ContentPath.
2. The icon file is 250x250 pixels in size or smaller.
3. $ContentPath is a directory that is named after the version of the application being created
4. The application has one deployment type that works for both 32 and 64-bit Windows 

#>
function New-Application {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$ContentPath,
        [Parameter(Mandatory)]
        [string]$Name,
        [Parameter(Mandatory)]
        [string]$Manufacturer,
        [string]$Description,
        [Parameter(Mandatory)]
        [string]$Icon,
        [Parameter(Mandatory)]
        [Microsoft.ConfigurationManagement.Cmdlets.Common.DetectionClause[]]$DetectionRule,
        [hashtable]$SupersedeLastVersion,
        [bool]$RemovePreviousVersionDeployments,
        [AllowEmptyString()]
        [string[]]$Dependencies,
        [scriptblock]$Deployments,
        [int]$EstimatedRuntimeMins,
        [int]$MaximumRuntimeMins,
        [AllowEmptyString()]
        [string[]]$TaskSequences,
        [int]$VersionsToKeep,
        [scriptblock]$Intune
    )

    # Get version number from content path's last directory name
    $Version = $ReplaceLegend.'%%Version%%'
    $AppName = "$Name $Version"

    # Create application
    $App = Get-CMApplication -Name "$AppName"
    if ($App) {
        Complete-Phase -Status OK
    }
    else {
        $AppSplat = @{
            Name = $AppName
            Publisher = $Manufacturer
            SoftwareVersion = $Version
            LocalizedName = $Name
            IconLocationFile = $Icon
            Description = $Description
            LocalizedDescription = $Description
        }
        $App = New-CMApplication @AppSplat
        $Script:Output 
        Complete-Phase -Status Success -Details $AppName
    }

    # Create deployment time
    Start-Phase -Phase DeploymentType
    $DTName = "$AppName (x86_64)"
    if (Get-CMDeploymentType -DeploymentTypeName $DTName -InputObject $App) {
        Complete-Phase -Status OK
    }
    else {
        $DTSplat = @{
            DeploymentTypeName = $DTName
            ContentLocation = $ContentPath
            InstallCommand = 'Deploy-Application.exe'
            UninstallCommand = '"Deploy-Application.exe" -DeploymentType "Uninstall" -DeployMode "Silent"'
            AddDetectionClause = $DetectionRule
            InstallationBehaviorType = 'InstallForSystem'
            LogonRequirementType = 'WhetherOrNotUserLoggedOn'
            EstimatedRuntimeMins = $EstimatedRuntimeMins
            MaximumRuntimeMins = $MaximumRuntimeMins
            InputObject = $App
        }
        $DT = Add-CMScriptDeploymentType @DTSplat
        # Set interaction after creation. The Add-CMScriptDeploymentType cmdlet is bugged and won't allow that
        # parameter to be set during creation unless LogonRequirementType is set to 'OnlyWhenUserLoggedOn'
        Set-CMDeploymentType -RequireUserInteraction $true -InputObject $DT -MsiOrScriptInstaller
        Complete-Phase -Status Success -Details $DTName
    }
    
    # Supersedence
    if ($SupersedeLastVersion.Enabled) {
        Start-Phase -Phase Supersedence
        $SupersedeResults = Set-Supersedence -Name $Name -Uninstall $SupersedeLastVersion.Uninstall
        Complete-Phase -Status $SupersedeResults.Status -Details $SupersedeResults.Details
    }

    if ($RemovePreviousVersionDeployments) {
        Start-Phase -Phase RemoveDeployments
        $RemoveDeployResults = Remove-OldDeployment -Name $Name
        Complete-Phase -Status $RemoveDeployResults.Status -Details $RemoveDeployResults.Details
    }

    # Dependencies
    if ($Dependencies) {
        Start-Phase -Phase Dependencies

        foreach ($Dependency in $Dependencies) {
            $Latest = Get-CMApplication -Name "$Dependency*" | Sort-Object -Property {[version]$_.SoftwareVersion} -Descending | Select-Object -First 1
            $LatestDT = Get-CMDeploymentType -ApplicationName $Latest.LocalizedDisplayName
            $Group = New-CMDeploymentTypeDependencyGroup -GroupName $Dependency -InputObject $DT
            Add-CMDeploymentTypeDependency -IsAutoInstall $true -DeploymentTypeDependency $LatestDT -InputObject $Group
        }

        Complete-Phase -Status Success
    }

    # Distribute content
    Start-Phase -Phase Distribute
    if ((Get-CMDistributionStatus -InputObject $App).Targeted -gt 0) {
        if ($Script:Results.Phases.Where{$_.Name -eq 'CopyFiles'}.Status -like 'Success*') {
            $DT = Get-CMDeploymentType -ApplicationName $AppName
            Update-CMDistributionPoint -ApplicationName $AppName -DeploymentTypeName $DT.LocalizedDisplayName
            Complete-Phase -Status Success -Details 'Updated content'
        }
        else {
            Complete-Phase -Status OK
        }
    }
    else {
        Start-CMContentDistribution -InputObject $App -DistributionPointGroupName 'Applications'
        Complete-Phase -Status Success
    }

    # Deploy
    if ($Deployments) {
        Start-Phase -Phase Deploy
        # Drop output down one line
        Write-Host -Object ''
        $Statuses = & $Deployments
        Complete-Phase -Status None -Details $Statuses
    }

    if ($TaskSequences) {
        Start-Phase -Phase UpdateTaskSequences
        # Drop output down one line
        Write-Host -Object ''
        $TSResults = Update-TaskSequence -ApplicationName $AppName -TaskSequence $TaskSequences
        Complete-Phase -Status None -Details $TSResults
    }

    if ($VersionsToKeep) {
        Start-Phase -Phase VersionCleanup
        $CleanupResults = Remove-OldAppVersion -Name $Name -Keep $VersionsToKeep
        if ($CleanupResults) {
            Complete-Phase -Status None -Details $CleanupResults
        }
        else {
            Complete-Phase -Status OK
        }
    }

    if ($Intune) {
        # Go back to the old console location so we can use UNC paths
        Pop-Location

        $IntuneSplat = @{
            SourceFolder = $ContentPath
            Icon = $Icon
            Name = $Name
            Version = $Version
            Description = $Description
            Publisher = $Manufacturer
            IntuneInfo = $Intune
            Detection = $DetectionRule
            VersionsToKeep = $VersionsToKeep
        }
        New-IntuneApplication @IntuneSplat
    }
}