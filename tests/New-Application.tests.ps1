$parent = Split-Path -Path $PSScriptRoot -Parent
$module = Split-Path -Path $parent -Leaf
$Resources = "$parent\src\Resources"
Remove-Module $module -Force -ErrorAction SilentlyContinue
Import-Module $parent\Src\$module.psd1 -Force
Import-Module "$Resources\ConfigurationManager\ConfigurationManager.psd1" -Force -Scope Global -ErrorAction SilentlyContinue

Describe "$module - New-Application" {
    InModuleScope PackageAutomation {
        function Get-CMApplication {}
        function New-CMApplication {}
        function Add-CMScriptDeploymentType {}
        function Set-CMDeploymentType {}
        function Get-CMDeploymentType {}
        function New-CMDeploymentTypeDependencyGroup {}
        function Add-CMDeploymentTypeDependency {}
        function Get-CMDistributionStatus {}
        function Update-CMDistributionPoint {}
        function Start-CMContentDistribution {}
        mock Get-CMApplication
        mock New-CMApplication
        mock Add-CMScriptDeploymentType
        mock Set-CMDeploymentType
        mock Get-CMDeploymentType
        mock New-CMDeploymentTypeDependencyGroup
        mock Add-CMDeploymentTypeDependency
        mock Get-CMDistributionStatus
        mock Update-CMDistributionPoint
        mock Start-CMContentDistribution
        mock Start-Phase
        mock Complete-Phase
        mock Set-Supersedence
        mock Remove-OldDeployment {@{Status = 'OK'}}
        mock Deploy
        mock Update-TaskSequence
        mock Remove-OldAppVersion
        mock Write-Host
        
        It 'Creates deployments if configured' {
            $ReplaceLegend = @{'%%VERSION%%' = [version]'1.0.0'}
            $Detect = File {
                FileName = 'code.exe'
                Path = '%PROGRAMFILES%\Microsoft VS Code'
                PropertyType = 'Version'
                ExpressionOperator = 'IsEquals'
                ExpectedValue = '1.0.0'
             }
            $RMDeploySplat = @{
                ContentPath = 'TestDrive:\TS'
                Name = 'TaskSequence'
                Manufacturer = 'Pester'
                DetectionRule = $Detect
                Icon = 'Z:\icon.png'
                Deployments = {
                    Deploy {
                        CollectionName = 'Pester'
                        DeployPurpose = 'Available'
                    }
                }
            }
            New-Application @RMDeploySplat
            Assert-MockCalled -CommandName Deploy -Scope It
        }

        It 'Does not attempt to run deployments section if not configured' {
            $ReplaceLegend = @{'%%VERSION%%' = [version]'1.0.0'}
            $Detect = File {
                FileName = 'code.exe'
                Path = '%PROGRAMFILES%\Microsoft VS Code'
                PropertyType = 'Version'
                ExpressionOperator = 'IsEquals'
                ExpectedValue = '1.0.0'
            }
            # Simulating if this was called by Invoke-PackageCreation since that would pass a null variable
            $RMDeploySplat = @{
                ContentPath = 'TestDrive:\TS'
                Name = 'TaskSequence'
                Manufacturer = 'Pester'
                DetectionRule = $Detect
                Icon = 'Z:\icon.png'
                Deployments = $null
            }
            New-Application @RMDeploySplat
            Assert-MockCalled -CommandName Deploy -Scope It -Times 0
        }

        It 'Removes previous verion deployments if RemovePreviousVersionDeployments is set to true' {
            $ReplaceLegend = @{'%%VERSION%%' = [version]'1.0.0'}
            $Detect = File {
                FileName = 'code.exe'
                Path = '%PROGRAMFILES%\Microsoft VS Code'
                PropertyType = 'Version'
                ExpressionOperator = 'IsEquals'
                ExpectedValue = '1.0.0'
             }
            $RMDeploySplat = @{
                ContentPath = 'TestDrive:\TS'
                Name = 'TaskSequence'
                Manufacturer = 'Pester'
                DetectionRule = $Detect
                Icon = 'Z:\icon.png'
                RemovePreviousVersionDeployments = $true
            }
            New-Application @RMDeploySplat
            Assert-MockCalled -CommandName Remove-OldDeployment -Scope It
        }
        
        It 'Updates task sequences if TaskSequences is set' {
            $ReplaceLegend = @{'%%VERSION%%' = [version]'1.0.0'}
            $Detect = File {
                FileName = 'code.exe'
                Path = '%PROGRAMFILES%\Microsoft VS Code'
                PropertyType = 'Version'
                ExpressionOperator = 'IsEquals'
                ExpectedValue = '1.0.0'
             }
            $TSSplat = @{
                ContentPath = 'TestDrive:\TS'
                Name = 'TaskSequence'
                Manufacturer = 'Pester'
                DetectionRule = $Detect
                Icon = 'Z:\icon.png'
                TaskSequences = 'Post-WinPE'
            }
            New-Application @TSSplat
            Assert-MockCalled -CommandName Update-TaskSequence -Scope It -ParameterFilter {
                $TaskSequence -eq 'Post-WinPE'
            }
        }
        
        It 'Performs Intune tasks if set' {
            mock New-IntuneApplication
            $ReplaceLegend = @{'%%VERSION%%' = [version]'1.0.0'}
            $Detect = File {
                FileName = 'code.exe'
                Path = '%PROGRAMFILES%\Microsoft VS Code'
                PropertyType = 'Version'
                ExpressionOperator = 'IsEquals'
                ExpectedValue = '1.0.0'
             }
             $IntuneSplat = @{
                ContentPath = 'C:\TS'
                Name = 'TaskSequence'
                Manufacturer = 'Pester'
                DetectionRule = $Detect
                Icon = 'Z:\icon.png'
                Intune = {
                    User = 'username'
                    Password = 'Password1'
                    Tenant = 'contoso.com'
                    Assignments = {
                        Assign {
                            Group = 'AllDevices'
                            Intent = 'available'
                        }
                    }
                }
            }
            New-Application @IntuneSplat
            Assert-MockCalled -CommandName New-IntuneApplication -Scope It
        }
        
        It 'Does not run Intune tasks if not set' {
            mock New-IntuneApplication
            $ReplaceLegend = @{'%%VERSION%%' = [version]'1.0.0'}
            $Detect = File {
                FileName = 'code.exe'
                Path = '%PROGRAMFILES%\Microsoft VS Code'
                PropertyType = 'Version'
                ExpressionOperator = 'IsEquals'
                ExpectedValue = '1.0.0'
             }
             # When invoked by Invoke-PackageCreation, if Intune is not set it will be an empty scriptblock. This simulates that.
             $NoIntuneSplat = @{
                ContentPath = 'C:\TS'
                Name = 'TaskSequence'
                Manufacturer = 'Pester'
                DetectionRule = $Detect
                Icon = 'Z:\icon.png'
                Intune = $null
            }
            New-Application @NoIntuneSplat
            Assert-MockCalled -CommandName New-IntuneApplication -Scope It -Times 0
        }

    }
}