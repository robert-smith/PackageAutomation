$parent = Split-Path -Path $PSScriptRoot -Parent
$module = Split-Path -Path $parent -Leaf
Remove-Module $module -Force -ErrorAction SilentlyContinue
Import-Module $parent\Src\$module.psd1 -Force

Describe "$module - Remove-OldDeployment" {
    InModuleScope PackageAutomation {
        function Get-CMApplicationDeployment {}
        function Remove-CMApplicationDeployment {}
        Mock Get-CMApplicationDeployment
        Mock Remove-CMApplicationDeployment
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

        It 'Does nothing if no old deployments are found' {
            $None = Remove-OldDeployment -Name 'Pester'
            $None.Status | Should -Be 'OK'
        }
        
        It 'Removes old deployments if they are found' {
            Mock Get-CMApplicationDeployment {@('Deploy1','Deploy2')}
            $Found = Remove-OldDeployment -Name 'Pester'
            $Found.Status | Should -Be 'Success'
            $Found.Details | Should -Be 'Removed 2 deployments.'
        }
    }
}