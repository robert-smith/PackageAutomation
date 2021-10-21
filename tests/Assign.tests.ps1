$parent = Split-Path -Path $PSScriptRoot -Parent
$module = Split-Path -Path $parent -Leaf
Remove-Module $module -Force -ErrorAction SilentlyContinue
Import-Module $parent\Src\$module.psd1 -Force

Describe "$module - Assign" {
    InModuleScope PackageAutomation {
        mock Get-PAIntuneWin32AppAssignment
        mock Add-PAIntuneWin32AppAssignmentAllDevices
        mock Add-PAIntuneWin32AppAssignmentAllUsers
        mock Add-PAIntuneWin32AppAssignmentGroup
        mock Get-AzureADGroup
        mock Write-Host
        mock Write-Error

        Context 'AllDevices' {
            $Script:IntuneAppLatest = @{
                id = 'alldevices'
            }
            $ScriptBlock = {
                Group = 'AllDevices'
                Intent = 'available'
                Include = $true
            }
            mock Expand-Placeholders {$ScriptBlock}
            Assign $ScriptBlock

            It 'Only runs Add-PAIntuneWin32AppAssignmentAllDevices when the group is AllDevices' {
                Assert-MockCalled -CommandName Add-PAIntuneWin32AppAssignmentAllDevices -Times 1 -Exactly -Scope Context
                Assert-MockCalled -CommandName Add-PAIntuneWin32AppAssignmentAllUsers -Times 0 -Scope Context
                Assert-MockCalled -CommandName Add-PAIntuneWin32AppAssignmentGroup -Times 0 -Scope Context
            }

            It 'Sets status to "Success" if assignment is added' {
                Assert-MockCalled -CommandName Write-Host -Times 1 -Exactly -Scope Context -ParameterFilter {
                    $Object -like '*Success:*All Devices'
                }
            }

            It 'Sets status to OK if assignment exists and does not run' {
                mock Get-PAIntuneWin32AppAssignment -ParameterFilter {$ID -eq 'alldevices'} -MockWith {@{target = @{'@odata.type' = '#microsoft.graph.allDevicesAssignmentTarget'}}}
                Assign $ScriptBlock
                Assert-MockCalled -CommandName Add-PAIntuneWin32AppAssignmentAllDevices -Times 0 -Scope It
                Assert-MockCalled -CommandName Add-PAIntuneWin32AppAssignmentAllUsers -Times 0 -Scope It
                Assert-MockCalled -CommandName Add-PAIntuneWin32AppAssignmentGroup -Times 0 -Scope It
                Assert-MockCalled -CommandName Write-Host -Times 1 -Exactly -Scope It -ParameterFilter {
                    $Object -like '*OK:*All Devices'
                }
            }

        }

        Context 'AllUsers' {
            $Script:IntuneAppLatest = @{
                id = 'allusers'
            }
            $ScriptBlock = {
                Group = 'AllUsers'
                Intent = 'available'
                Include = $true
            }
            mock Expand-Placeholders {$ScriptBlock}
            Assign $ScriptBlock

            It 'Only runs Add-PAIntuneWin32AppAssignmentAllUsers when the group is AllUsers' {
                Assert-MockCalled -CommandName Add-PAIntuneWin32AppAssignmentAllDevices -Times 0 -Scope Context
                Assert-MockCalled -CommandName Add-PAIntuneWin32AppAssignmentAllUsers -Times 1 -Exactly -Scope Context
                Assert-MockCalled -CommandName Add-PAIntuneWin32AppAssignmentGroup -Times 0 -Scope Context
            }

            It 'Sets status to "Success" if assignment is added' {
                Assert-MockCalled -CommandName Write-Host -Times 1 -Exactly -Scope Context -ParameterFilter {
                    $Object -like '*Success:*All Users'
                }
            }

            It 'Sets status to OK if assignment exists and does not run' {
                mock Get-PAIntuneWin32AppAssignment -ParameterFilter {$ID -eq 'allusers'} -MockWith {@{target = @{'@odata.type' = '#microsoft.graph.allLicensedUsersAssignmentTarget'}}}
                Assign $ScriptBlock
                Assert-MockCalled -CommandName Add-PAIntuneWin32AppAssignmentAllDevices -Times 0 -Scope It
                Assert-MockCalled -CommandName Add-PAIntuneWin32AppAssignmentAllUsers -Times 0 -Scope It
                Assert-MockCalled -CommandName Add-PAIntuneWin32AppAssignmentGroup -Times 0 -Scope It
                Assert-MockCalled -CommandName Write-Host -Times 1 -Exactly -Scope It -ParameterFilter {
                    $Object -like '*OK:*All Users'
                }
            }
        }

        Context 'Group' {
            $Script:IntuneAppLatest = @{
                id = 'group'
            }
            $ScriptBlock = {
                Group = 'Custom Group'
                Intent = 'available'
            }
            mock Expand-Placeholders {$ScriptBlock}
            mock Get-AzureADGroup {@{ObjectId = 123}}
            Assign $ScriptBlock

            
            It 'Only runs Add-PAIntuneWin32AppAssignmentGroup when the group is neither AllDevices or AllUsers' {
                Assert-MockCalled -CommandName Add-PAIntuneWin32AppAssignmentAllDevices -Times 0 -Scope Context
                Assert-MockCalled -CommandName Add-PAIntuneWin32AppAssignmentAllUsers -Times 0 -Scope Context
                Assert-MockCalled -CommandName Add-PAIntuneWin32AppAssignmentGroup -Times 1 -Exactly -Scope Context
            }
            
            It 'Sets Include to true if Exclude is not set' {
                Assert-MockCalled -CommandName Add-PAIntuneWin32AppAssignmentGroup -Times 1 -Scope Context -ParameterFilter {
                    $Include -eq $true -and
                    $Exclude -eq $null
                }
            }

            It 'Sets status to "Success" if assignment is added' {
                Assert-MockCalled -CommandName Write-Host -Times 1 -Exactly -Scope Context -ParameterFilter {
                    $Object -like '*Success:*Custom Group'
                }
            }

            It 'Does not set Include to true if Exclude is set' {
                $ScriptBlock = {
                    Group = 'Custom Group'
                    Intent = 'available'
                    Exclude = $true
                }
                Assign $ScriptBlock
                
                Assert-MockCalled -CommandName Add-PAIntuneWin32AppAssignmentGroup -Times 1 -Scope It -ParameterFilter {
                    $Exclude -eq $true -and
                    $Include -eq $null
                }
            }

            It 'Sets status to OK if assignment exists and does not run' {
                mock Get-PAIntuneWin32AppAssignment -ParameterFilter {$ID -eq 'group'} -MockWith {@{target = @{groupId = 123}}}
                Assign $ScriptBlock
                Assert-MockCalled -CommandName Add-PAIntuneWin32AppAssignmentAllDevices -Times 0 -Scope It
                Assert-MockCalled -CommandName Add-PAIntuneWin32AppAssignmentAllUsers -Times 0 -Scope It
                Assert-MockCalled -CommandName Add-PAIntuneWin32AppAssignmentGroup -Times 0 -Scope It
                Assert-MockCalled -CommandName Write-Host -Times 1 -Exactly -Scope It -ParameterFilter {
                    $Object -like '*OK:*Custom Group'
                }
            }

            It 'Throws an error if the group does not exist in Azure AD' {
                mock Get-AzureADGroup {$false}
                {Assign $ScriptBlock -ErrorAction Stop} | Should -Throw
                Assert-MockCalled -CommandName Add-PAIntuneWin32AppAssignmentGroup -Times 0 -Scope It
                Assert-MockCalled -CommandName Write-Error -Scope It -Times 1
                Assert-MockCalled -CommandName Write-Host -Times 0 -Scope It
            }

        }
    }
}