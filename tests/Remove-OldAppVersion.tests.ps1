$parent = Split-Path -Path $PSScriptRoot -Parent
$module = Split-Path -Path $parent -Leaf
Remove-Module $module -Force -ErrorAction SilentlyContinue
Import-Module $parent\Src\$module.psd1 -Force

Describe "$module - Set-Supersedence" {
    InModuleScope PackageAutomation {
        function Get-CMApplication {
            param ($Name)
            return @{LocalizedDisplayName = $Name}
        }
        function Get-CMApplicationDeployment {}
        function Remove-CMApplicationDeployment {}
        function Remove-CMApplication {
            param(
                [parameter(ValueFromPipeline = $true)]$InputObject,
                [switch]$Force
            )
        }
        Mock Get-OrderedAppVersion {
            @(
                @{LocalizedDisplayName = 'Pester 5.0'}
                @{LocalizedDisplayName = 'Pester 4.0'}
                @{LocalizedDisplayName = 'Pester 3.0'}
                @{LocalizedDisplayName = 'Pester 2.0'}
                @{LocalizedDisplayName = 'Pester 1.0'}
            )
        }
        Mock Remove-CMApplication
        Mock Write-Host

        $Results = Remove-OldAppVersion -Name Pester -Keep 3

        It 'Keeps the desingated number of most recent app versions' {
            Assert-MockCalled -Exactly -Times 0 -CommandName Remove-CMApplication -ParameterFilter {
                $InputObject.LocalizedDisplayName -eq 'Pester 5.0' -or
                $InputObject.LocalizedDisplayName -eq 'Pester 4.0' -or
                $InputObject.LocalizedDisplayName -eq 'Pester 3.0'
            }
        }

        It 'Removes all apps outside of the number to keep' {
            Assert-MockCalled -Exactly -Times 1 -CommandName Remove-CMApplication -ParameterFilter {
                $InputObject.LocalizedDisplayName -eq 'Pester 2.0'
            }
            Assert-MockCalled -Exactly -Times 1 -CommandName Remove-CMApplication -ParameterFilter {
                $InputObject.LocalizedDisplayName -eq 'Pester 1.0'
            }
        }

        It 'Does nothing if the number of versions to keep matches the number of versions in SCCM' {
            Remove-OldAppVersion -Name Pester -Keep 5
            Assert-MockCalled -Exactly -Times 0 -CommandName Remove-CMApplication -Scope It
        }

        It 'Outputs the apps that were removed in the correct format' {
            $Results | Should -Not -Contain 'Success: Pester 5.0'
            $Results | Should -Not -Contain 'Success: Pester 4.0'
            $Results | Should -Not -Contain 'Success: Pester 3.0'
            $Results | Should -Contain 'Success: Pester 2.0'
            $Results | Should -Contain 'Success: Pester 1.0'
        }

    }
}