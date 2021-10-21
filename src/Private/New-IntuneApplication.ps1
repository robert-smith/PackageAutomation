function New-IntuneApplication {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $SourceFolder,
        [Parameter(Mandatory)]
        [version] $Version,
        [Parameter(Mandatory)]
        [string] $Icon,
        [Parameter(Mandatory)]
        [string] $Name,
        [string] $Description = 'None.',
        [Parameter(Mandatory)]
        [string] $Publisher,
        [AllowNull()]
        [System.Nullable[int]] $VersionsToKeep,
        [ValidateSet(
            'system',
            'user'
        )]
        [string] $InstallExperience = 'system',
        [ValidateSet(
            'allow',
            'basedOnReturnCode',
            'force',
            'suppress'
        )]
        [string] $RestartBehavior = 'suppress',
        [Parameter(Mandatory)]
        [Microsoft.ConfigurationManagement.Cmdlets.Common.DetectionClause[]] $Detection,
        [Parameter(Mandatory)]
        [scriptblock] $IntuneInfo
    )
    
    Start-Phase -Phase IntuneConnect
    # Form credentials and connect to Graph and AzureAD
    $Config = Convert-ScriptBlockToHashtable -ScriptBlock $IntuneInfo
    $Password = ConvertTo-SecureString -String $Config.Password -AsPlainText -Force
    $Credentials = [pscredential]::new($Config.User,$Password)
    Connect-PAMSIntuneGraph -TenantName $Config.Tenant -Credential $Credentials -WarningAction SilentlyContinue > $null
    Connect-AzureAD -Credential $Credentials > $null
    Complete-Phase -Status Done

    Start-Phase -Phase IntuneAdd
    # Generate detection rule(s)
    $ConvertedDetection = Convert-DetectionToIntune -Detection $Detection
    # Check if app exists. Store it in a script variable so that it can be referenced by child
    # functions such as Assign.
    $Apps = Get-PAIntuneWin32App -DisplayName $Name -WarningAction SilentlyContinue
    $Script:IntuneAppLatest = $Apps | Where-Object -FilterScript {$_.displayVersion -eq $Version}
    $Changes = $Script:Results.Phases.Where{$_.Name -eq 'CopyFiles'}.Status -like 'Success*'
    if ($Changes -or -not $IntuneAppLatest) {
        # Package app
        $ModuleDir = Split-Path -Path $PSScriptRoot -Parent
        # Copy package files locally along with ServiceUIx64 so that users can see the PSADT UI
        Copy-Item -Path "$SourceFolder\*" -Destination $PATempDir -Recurse -Container -Force
        Copy-Item -Path "$ModuleDir\Resources\ServiceUIx64.exe" -Destination $PATempDir -Force
        $Package = New-PAIntuneWin32AppPackage -SourceFolder $PATempDir -SetupFile 'Deploy-Application.exe' -OutputFolder $PATempDir -Quiet
    }
    if ($IntuneAppLatest -and -not $Changes) {
        # Sort the apps to be used for later steps if needed
        $AppStatus = 'OK'
    }
    elseif ($IntuneAppLatest -and $Changes) {
        $Script:IntuneAppLatest = Update-PAIntuneWin32AppPackageFile -ID $IntuneAppLatest.id -FilePath $Package.Path
        $AppStatus = 'Success'
        $Details = 'Updated package file'
    }
    else {
        # Add app to Intune
        $IconConverted = New-PAIntuneWin32AppIcon -FilePath $Icon
        $AppSplat = @{
            FilePath = $Package.Path
            DisplayName = $Name
            DisplayVersion = $Version
            Description = $Description
            Publisher = $Publisher
            InstallExperience = $InstallExperience
            RestartBehavior = $RestartBehavior
            DetectionRule = $ConvertedDetection
            Icon = $IconConverted
            InstallCommandLine = 'ServiceUIx64.exe -Process:explorer.exe Deploy-Application.exe'
            UninstallCommandLine = '"Deploy-Application.exe" -DeploymentType "Uninstall" -DeployMode "Silent"'
        }

        # Store new app output in a Script scoped variable so child functions can access it
        $Script:IntuneAppLatest = Add-PAIntuneWin32App @AppSplat
        # Get the new list of apps
        $Apps = Get-PAIntuneWin32App -DisplayName $Name -WarningAction SilentlyContinue
        $AppStatus = 'Success'
    }
    # Sort the apps in case they need to be used for later steps
    $Sorted = $Apps | Sort-Object -Property {[version]$_.DisplayVersion} -Descending
    Complete-Phase -Status $AppStatus -Details $Details

    if ($Config.RemovePreviousAssignments) {
        Start-Phase -Phase IntuneRemoveAssignments
        $Unassign = $Sorted | Select-Object -Skip 1
        if ($Unassign.Count -eq 0) {
            Complete-Phase -Status OK
        }
        else {
            # Drop output down one line
            Write-Host -Object ''
            $UnassignResults = foreach ($App in $Unassign) {
                $Assigns = Get-PAIntuneWin32AppAssignment -ID $App.id
                if ($Assigns) {
                    Remove-PAIntuneWin32AppAssignment -ID $App.id
                    $Status = 'Success'
                    $Color = $ANSI.Yellow
                }
                else {
                    $Status = 'OK'
                    $Color = $ANSI.Green
                }
                Write-Host -Object ('    - ' + $Color + $Status + ': ' + $ANSI.Reset + $App.DisplayName + ' ' + $App.DisplayVersion)
                Write-Output -InputObject ($Status + ': ' + $App.DisplayName + ' ' + $App.DisplayVersion)
            }
            Complete-Phase -Status None -Details $UnassignResults
        }
    }

    if ($Config.Assignments) {
        Start-Phase -Phase IntuneAssign
        # Drop output down one line
        Write-Host -Object ''
        # Ensure only Assignment commands are in the Assignments scriptblock
        $Commands = $Config.Assignments.Ast.EndBlock.Statements.PipelineElements.foreach{$_.CommandElements.Value}
        if ($Commands.Where{$_ -ne 'Assign'}) {
            Write-Error -Message 'A command other than Assign was detected. Stopping execution.'
        }
        else {
            $Results = & $Config.Assignments
            Complete-Phase -Status None -Details $Results
        }
    }

    # Remove-PAIntuneWin32App is not implemented yet
    #if ($VersionsToKeep) {
    #    Start-Phase -Phase IntuneVersionCleanup
    #    $Old = $Sorted | Select-Object -Skip $VersionsToKeep
    #    foreach ($App in $Old) {
    #        
    #    }
    #}
}