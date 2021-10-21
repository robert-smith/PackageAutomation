$parent = Split-Path -Path $PSScriptRoot -Parent
$module = Split-Path -Path $parent -Leaf
Remove-Module $module -Force -ErrorAction SilentlyContinue
Import-Module $parent\Src\$module.psd1 -Force

Describe "$module - Set-Supersedence" {
    InModuleScope PackageAutomation {
        
        # Create dummy functions for CM cmdlets to make them easier to mock
        function Get-CMDeploymentType {param ($ApplicationName)}
        function Set-CMDeploymentTypeSupersedence {param (
            $SupersedingDeploymentType,
            $InputObject,
            $IsUninstall
        )}
        function Add-CMDeploymentTypeSupersedence {param (
            $SupersedingDeploymentType,
            $SupersededDeploymentType,
            $IsUninstall
        )}
        function Get-Supersedence {}

        Mock Get-OrderedAppVersion {
            @(
                [pscustomobject]@{
                    LocalizedDisplayName = 'Current'
                    SoftwareVersion = '1.11.0'
                },
                [pscustomobject]@{
                    LocalizedDisplayName = 'Old'
                    SoftwareVersion = '1.2.0'
                }
            )
        }
        Mock Set-CMDeploymentTypeSupersedence
        Mock Add-CMDeploymentTypeSupersedence
        Mock Get-Supersedence {[pscustomobject]@{
            LogicalName = 'DeploymentType_4241a185-f3c2-4423-a9a4-287bad7c94a1'
            Changeable = 'false'
        }}
        Context 'Set' {
            $UniqueID = 'ScopeId_3102A16B-832E-41D2-B431-4FDB879CC0DD/DeploymentType_4241a185-f3c2-4423-a9a4-287bad7c94a1/1'
            Mock Get-CMDeploymentType -ParameterFilter {$ApplicationName -eq 'Current'} -MockWith {@{Name = 'CurrentDT';CI_UniqueID = $UniqueID}}
            Mock Get-CMDeploymentType -ParameterFilter {$ApplicationName -eq 'Old'} -MockWith {@{Name = 'OldDT';CI_UniqueID = $UniqueID}}

            $Results = Set-Supersedence -Name 'Success' -Uninstall $true

            It 'Outputs success and details when changes are made' {
                $Results.Status | Should -Be 'Success'
                $Results.Details | Should -Be 'Uninstall mode changed to true'
            }
    
            It 'Passes correct parameters to Set-CMDeploymentTypeSupersedence' {
                Assert-MockCalled -CommandName Set-CMDeploymentTypeSupersedence -Times 1 -Exactly -Scope Context -ParameterFilter {
                    $IsUninstall -eq $true -and
                    $SupersedingDeploymentType.Name -eq 'OldDT' -and
                    $InputObject.Name -eq 'CurrentDT'
                }
            }

        }

        Context 'Add' {
            $UniqueID = 'ScopeId_3102A16B-832E-41D2-B431-4FDB879CC0DD/DeploymentType_11111111-f3c2-4423-a9a4-287bad7c94a1/1'
            Mock Get-CMDeploymentType -ParameterFilter {$ApplicationName -eq 'Current'} -MockWith {@{Name = 'CurrentDT';CI_UniqueID = $UniqueID}}
            Mock Get-CMDeploymentType -ParameterFilter {$ApplicationName -eq 'Old'} -MockWith {@{Name = 'OldDT';CI_UniqueID = $UniqueID}}
            
            $Results = Set-Supersedence -Name 'OK' -Uninstall $true

            It 'Outputs success and details when adding supersedence' {
                $Results.Status | Should -Be 'Success'
                $Results.Details | Should -Be 'Uninstall mode set to true'
            }

            It 'Passes correct parameters to Add-CMDeploymentTypeSupersedence' {
                Assert-MockCalled -CommandName Add-CMDeploymentTypeSupersedence -Times 1 -Exactly -Scope Context -ParameterFilter {
                    $IsUninstall -eq $true -and
                    $SupersedingDeploymentType.Name -eq 'CurrentDT' -and
                    $SupersededDeploymentType.Name -eq 'OldDT'
                }
            }
        }

        Context 'Compliant' {
            $UniqueID = 'ScopeId_3102A16B-832E-41D2-B431-4FDB879CC0DD/DeploymentType_4241a185-f3c2-4423-a9a4-287bad7c94a1/1'
            Mock Get-CMDeploymentType -ParameterFilter {$ApplicationName -eq 'Current'} -MockWith {@{Name = 'CurrentDT';CI_UniqueID = $UniqueID}}
            Mock Get-CMDeploymentType -ParameterFilter {$ApplicationName -eq 'Old'} -MockWith {@{Name = 'OldDT';CI_UniqueID = $UniqueID}}
            
            $Results = Set-Supersedence -Name 'OK' -Uninstall $false

            It 'Outputs OK when supersedence is compliant' {
                $Results.Status | Should -Be 'OK'
                $Results.Details | Should -BeNullOrEmpty
            }

            It 'Outputs OK when there are no older apps to supersede' {
                Mock Get-OrderedAppVersion {[pscustomobject]@{
                    LocalizedDisplayName = 'Current'
                    SoftwareVersion = '1.11.0'
                }}

                $Results2 = Set-Supersedence -Name 'OK' -Uninstall $false
                $Results2.Status | Should -Be 'OK'
                $Results2.Details | Should -Be 'No older versions found'
                Assert-MockCalled -CommandName Get-CMDeploymentType -Scope It -Exactly -Times 0 -ParameterFilter {
                    $ApplicationName -ne 'Current'
                }
            }
        }
    }
}