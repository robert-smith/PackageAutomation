$parent = Split-Path -Path $PSScriptRoot -Parent
$module = Split-Path -Path $parent -Leaf
Remove-Module $module -Force -ErrorAction SilentlyContinue
Import-Module $parent\Src\$module.psd1 -Force

Describe "$module - Update-TaskSequence" {
    InModuleScope PackageAutomation {
        function Get-CMTSStepInstallApplication {param($TaskSequenceName)}
        function Set-CMTSStepInstallApplication {param($Application,$TaskSequenceName)}
        function Get-CMApplication {param($Name);return $Name}
        Mock Write-Host
        Mock Set-CMTSStepInstallApplication
        Mock Get-CMTSStepInstallApplication -ParameterFilter {$TaskSequenceName -eq 'OKTS'} {
            [PSCustomObject]@{
                Name = 'OKTS'
                AppInfo = @(
                    @{DisplayName = 'Adobe Reader 1.1.1'}
                    @{DisplayName = 'Google Chrome 2.2.2.2'}
                    @{DisplayName = 'Pester 3.3.3'}
                    @{DisplayName = 'Microsoft Office 4.4.4'}
                )
            }
        }
        Mock Get-CMTSStepInstallApplication -ParameterFilter {$TaskSequenceName -eq 'UpdateTS'} {
            [PSCustomObject]@{
                Name = 'UpdateTS'
                AppInfo = @(
                    @{DisplayName = 'Adobe Reader 1.1.1'}
                    @{DisplayName = 'Google Chrome 2.2.2'}
                    @{DisplayName = 'Pester 2.3.3'}
                    @{DisplayName = 'Microsoft Office 4.4.4'}
                )
            }
        }

        $Results = Update-TaskSequence -ApplicationName 'Pester 3.3.3' -TaskSequence 'OKTS', 'UpdateTS'
        It 'Marks task sequence as OK if correct version of application is present' {
            $Results.Where{$_ -match 'OKTS'} | Should -Be 'OK: OKTS'
        }
        
        It 'Marks task sequence as Success if version has been updated' {
            $Results.Where{$_ -match 'UpdateTS'} | Should -Be 'Success: UpdateTS'
        }

        It 'Removes the old app from task sequences and replaces it with the new version' {
            Assert-MockCalled -CommandName Set-CMTSStepInstallApplication -ParameterFilter {
                $TaskSequenceName -eq 'UpdateTS' -and
                'Pester 3.3.3' -in $Application -and
                'Pester 2.3.3' -notin $Application
            }
        }

        It 'Leaves all other apps in the task sequence alone' {
            Assert-MockCalled -CommandName Set-CMTSStepInstallApplication -ParameterFilter {
                $TaskSequenceName -eq 'UpdateTS' -and
                $Application.Count -eq 4 -and
                'Microsoft Office 4.4.4' -in $Application -and
                'Adobe Reader 1.1.1' -in $Application -and
                'Google Chrome 2.2.2' -in $Application
            }
        }

        It 'Does not attempt to update a task sequence if the new version is already present' {
            Assert-MockCalled -Exactly -Times 0 -CommandName Set-CMTSStepInstallApplication -ParameterFilter {
                $InputObject.Name -eq 'OKTS'
            }
        }
    }
}