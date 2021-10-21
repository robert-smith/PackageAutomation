$parent = Split-Path -Path $PSScriptRoot -Parent
$module = Split-Path -Path $parent -Leaf
Remove-Module $module -Force -ErrorAction SilentlyContinue
Import-Module $parent\Src\$module.psd1 -Force

Describe "$module - Get-PreviousAppVersion" {
    InModuleScope PackageAutomation {
        function Get-CMApplication {param ($Name)}
        Mock Get-CMApplication {
            @(
                [pscustomobject]@{
                    LocalizedDisplayName = 'Oldest'
                    SoftwareVersion = '1.1.99'
                },
                [pscustomobject]@{
                    LocalizedDisplayName = 'Current'
                    SoftwareVersion = '1.11.0'
                },
                [pscustomobject]@{
                    LocalizedDisplayName = 'Old'
                    SoftwareVersion = '1.2.11'
                },
                [pscustomobject]@{
                    LocalizedDisplayName = 'Older'
                    SoftwareVersion = '1.2.2'
                }
            )
        }
        
        It 'Correctly sorts the apps by version number' {
            $Result = Get-OrderedAppVersion -Name 'Pester'
            $Result[0].LocalizedDisplayName | Should -Be 'Current'
            $Result[1].LocalizedDisplayName | Should -Be 'Old'
            $Result[2].LocalizedDisplayName | Should -Be 'Older'
            $Result[3].LocalizedDisplayName | Should -Be 'Oldest'
        }
    }
}