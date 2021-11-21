$parent = Split-Path -Path $PSScriptRoot -Parent
$module = Split-Path -Path $parent -Leaf
Remove-Module $module -Force -ErrorAction SilentlyContinue
Import-Module $parent\Src\$module.psd1 -Force
$CMDlls = Get-ChildItem -Path "$PSScriptRoot\ConfigurationManager\*.dll"
foreach ($Dll in $CMDlls) {
    [Reflection.Assembly]::LoadFile($Dll.FullName) | out-null
}
Import-Module "$PSScriptRoot\ConfigurationManager\ConfigurationManager.psd1" -Force -Scope Global -ErrorAction SilentlyContinue

Describe "$module - New-IntuneApplication" {
    InModuleScope PackageAutomation {
        
        Context 'Logic' {
            $LogicSplat = @{
                SourceFolder = 'Z:\Logic'
                Version = '1.2.3'
                Icon = 'Z:\Logic\icon.png'
                Name = 'Exists'
                Publisher = 'Pester'
                VersionsToKeep = 3
                Detection = (File {
                    FileName = 'Logic.exe'
                    Path = '%PROGRAMFILES%\Logic'
                    PropertyType = 'Version'
                    ExpectedValue = '1.2.3'
                    ExpressionOperator = 'IsEquals'
                })
                IntuneInfo = {
                    User = 'user'
                    Password = 'pass'
                    Tenant = 'contoso.com'
                    RemovePreviousAssignments = $true
                    Assignments = {
                        Assign {
                            Group = 'Pester'
                            Intent = 'available'
                            Include = $true
                        }
                    }
                }
            }
            $MissingSplat = $LogicSplat.Clone()
            $MissingSplat.Name = 'Missing'

            mock Connect-PAMSIntuneGraph
            mock Connect-AzureAD
            mock New-PAIntuneWin32AppPackage { @{Path = 'Z:\Logic\Logic.intunewin' } }
            mock Copy-Item
            mock New-PAIntuneWin32AppIcon { 'stuff' }
            mock Add-PAIntuneWin32App
            mock Write-Host
            mock Get-PAIntuneWin32AppAssignment
            mock Remove-PAIntuneWin32AppAssignment
            mock Update-PAIntuneWin32AppPackageFile
            mock Start-Phase
            mock Complete-Phase
            mock Assign
            mock Write-Error
            $Script:PATempDir = 'Z:\Temp'
            $Script:Results = @{Phases = @(@{Name = 'CopyFiles'; Status = 'Success' }) }
            
            Context 'Connecting' {
                mock Get-PAIntuneWin32App -MockWith { @{id = 12345; displayVersion = '1.2.3' } } -ParameterFilter {$DisplayName -eq 'Exists'}
                Mock Get-PAIntuneWin32App {} -ParameterFilter { $DisplayName -eq 'Missing' }

                New-IntuneApplication @LogicSplat
                
                It 'Passes the correct info to Connect-PAMSIntuneGraph' {
                    $MSIntuneGraphSplat = @{
                        CommandName = 'Connect-PAMSIntuneGraph'
                        Times = 1
                        Exactly = $true
                        Scope = 'Context'
                        ParameterFilter = {
                            $Credential.UserName -eq 'user' -and
                            $Credential.GetNetworkCredential().Password -eq 'pass' -and
                            $TenantName -eq 'contoso.com'
                        }
                    }
                    Assert-MockCalled @MSIntuneGraphSplat
                }
                
                It 'Passes the correct info to Connect-AzureAD' {
                    $MSIntuneGraphSplat = @{
                        CommandName = 'Connect-AzureAD'
                        Times = 1
                        Exactly = $true
                        ParameterFilter = {
                            $Credential.UserName -eq 'user' -and
                            $Credential.GetNetworkCredential().Password -eq 'pass'
                        }
                    }
                    Assert-MockCalled @MSIntuneGraphSplat
                }
            }

            Context 'Creation' {

                mock Get-PAIntuneWin32App -MockWith { @{id = 12345; displayVersion = '1.2.3' } } -ParameterFilter {$DisplayName -eq 'Exists'}
                Mock Get-PAIntuneWin32App {} -ParameterFilter { $DisplayName -eq 'Missing' }

                It 'Creates a new app if latest version is not found in Intune' {
                    New-IntuneApplication @MissingSplat
                    Assert-MockCalled -CommandName Add-PAIntuneWin32App -Times 1 -Exactly -Scope It
                }
                
                It 'Creates a new app if latest version is not found in Intune, but is already compliant in SCCM' {
                    $Script:Results = @{Phases = @(@{Name = 'CopyFiles'; Status = 'OK' }) }
                    New-IntuneApplication @MissingSplat
                    Assert-MockCalled -CommandName Add-PAIntuneWin32App -Times 1 -Exactly -Scope It
                }

                It 'Sets the version when creating the app' {
                    New-IntuneApplication @MissingSplat
                    Assert-MockCalled -CommandName Add-PAIntuneWin32App -Times 1 -Exactly -Scope It -ParameterFilter {
                        $DisplayVersion -eq '1.2.3'
                    }
                }

                It 'Sets the publisher when creating the app' {
                    New-IntuneApplication @MissingSplat
                    Assert-MockCalled -CommandName Add-PAIntuneWin32App -Times 1 -Exactly -Scope It -ParameterFilter {
                        $Publisher -eq 'Pester'
                    }
                }

                It 'Updates package file if app exists and file changes are detected' {
                    $Script:Results = @{Phases = @(@{Name = 'CopyFiles'; Status = 'Success' }) }
                    New-IntuneApplication @LogicSplat
                    Assert-MockCalled -CommandName Update-PAIntuneWin32AppPackageFile -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Add-PAIntuneWin32App -Times 0 -Exactly -Scope It
                }

                It 'Skips trying to create if the latest version is found in Intune' {
                    $Script:Results = @{Phases = @(@{Name = 'CopyFiles'; Status = 'OK'})}
                    New-IntuneApplication @LogicSplat
                    Assert-MockCalled -CommandName Add-PAIntuneWin32App -Times 0 -Exactly -Scope It
                }
            }

            Context 'Remove Assignments' {
                $Script:Results = @{Phases = @(@{Name = 'CopyFiles'; Status = 'Success'})}
                mock Get-PAIntuneWin32App {@(
                    @{id = 1;displayVersion = '1.2.3'}
                    @{id = 2;displayVersion = '1.2.4'}
                    @{id = 3;displayVersion = '1.2.5'}
                )
                }
                mock Get-PAIntuneWin32AppAssignment -ParameterFilter {$id -eq 2} -MockWith {
                    $true
                }
                New-IntuneApplication @LogicSplat

                It 'Removes assignments if found' {
                    Assert-MockCalled -CommandName Remove-PAIntuneWin32AppAssignment -Scope Context
                }

                It 'Tries to remove only if assignments found' {
                    Assert-MockCalled -CommandName Remove-PAIntuneWin32AppAssignment -Scope Context -Times 1 -Exactly
                }

                It 'Does not run if RemovePreviousAssignments is not set' {
                    $LogicSplat.IntuneInfo = {
                        User = 'user'
                        Password = 'pass'
                        Tenant = 'contoso.com'
                        Assignments = {
                            Assign {
                                Group = 'Pester'
                                Intent = 'available'
                                Include = $true
                            }
                        }
                    }
                    New-IntuneApplication @LogicSplat

                    Assert-MockCalled -CommandName Start-Phase -Exactly -Times 0 -ParameterFilter { $Phase -eq 'IntuneRemoveAssignments' } -Scope It
                }

            }

            Context 'Add assignments' {
                New-IntuneApplication @LogicSplat

                It 'Runs the Assignments phase if Assignments is set' {
                    Assert-MockCalled -CommandName Start-Phase -Exactly -Times 1 -ParameterFilter { $Phase -eq 'IntuneAssign' } -Scope Context
                }

                It 'Runs the scriptblock if everything is okay' {
                    Assert-MockCalled -CommandName Assign -Scope Context -Times 1 -Exactly
                }

                It 'Does not run the scriptblock if a command other than Assign is found' {
                    $LogicSplat.IntuneInfo = {
                        User = 'user'
                        Password = 'pass'
                        Tenant = 'contoso.com'
                        Assignments = {
                            Assign {
                                Group = 'Pester'
                                Intent = 'available'
                                Include = $true
                            }
                            Get-ChildItem
                        }
                    }
                    New-IntuneApplication @LogicSplat

                    Assert-MockCalled -CommandName Write-Error -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Assign -Scope It -Times 0 -Exactly
                }
                
                It 'Does not run the Assignments phase if Assignments is not set' {
                    $LogicSplat.IntuneInfo = {
                        User = 'user'
                        Password = 'pass'
                        Tenant = 'contoso.com'
                    }
                    New-IntuneApplication @LogicSplat

                    Assert-MockCalled -CommandName Start-Phase -Times 0 -Exactly -Scope It -ParameterFilter {
                        $Phase -eq 'IntuneAssign'
                    }

                }
            }
        }
    }

}