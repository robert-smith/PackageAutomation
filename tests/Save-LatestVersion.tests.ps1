$parent = Split-Path -Path $PSScriptRoot -Parent
$module = Split-Path -Path $parent -Leaf
Remove-Module $module -Force -ErrorAction SilentlyContinue
Import-Module $parent\Src\$module.psd1 -Force

Describe "$module - Save-LatestVersion" {
    InModuleScope PackageAutomation {
        
        Mock Start-Phase
        Mock Complete-Phase
        Mock Start-FileDownload

        It 'Does not change file name if Version is not specified in Metadata' {
            Save-LatestVersion -URL 'https://download.pester.com/releases/pester1.2.3.0.exe' -Destination 'TestDrive:\Pester' -Metadata {}
            Assert-MockCalled -CommandName Start-FileDownload -Scope It -ParameterFilter {$Destination -like '*pester1.2.3.0.exe'}
        }
        
        It 'Changes file name if Version is specified in Metadata' {
            Save-LatestVersion -URL 'https://download.pester.com/releases/pester.exe' -Destination 'TestDrive:\Pester' -Metadata {Version = '1.2.3.0'}
            Assert-MockCalled -CommandName Start-FileDownload -Scope It -ParameterFilter {$Destination -like '*pester-1.2.3.0.exe'}
        }
        
        It 'Converts escaped URL characters' {
            Save-LatestVersion -URL 'https://download.pester.com/releases/pester%201.2.3.0.exe' -Destination 'TestDrive:\Pester' -Metadata {}
            Assert-MockCalled -CommandName Start-FileDownload -Scope It -ParameterFilter {$Destination -like '*pester 1.2.3.0.exe'}
        }

    }
}