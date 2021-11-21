$parent = Split-Path -Path $PSScriptRoot -Parent
$module = Split-Path -Path $parent -Leaf
Remove-Module $module -Force -ErrorAction SilentlyContinue
Import-Module $parent\Src\$module.psd1 -Force
$CMDlls = Get-ChildItem -Path "$PSScriptRoot\ConfigurationManager\*.dll"
foreach ($Dll in $CMDlls) {
    [Reflection.Assembly]::LoadFile($Dll.FullName) | out-null
}
Import-Module "$PSScriptRoot\ConfigurationManager\ConfigurationManager.psd1" -Force -Scope Global -ErrorAction SilentlyContinue

Describe "$module - Invoke-PackageCreation" {
    InModuleScope PackageAutomation {
        mock Save-LatestVersion
        mock Get-InstallerProperties
        mock Expand-Placeholders
        mock Convert-ScriptblockToHashtable
        mock Copy-ApplicationFiles
        mock Push-Location
        mock Connect-SCCM
        mock Invoke-DetectionRules
        mock Start-Phase
        mock Complete-Phase
        mock New-Application

        It 'Throw if InstallWelcomeParams is wrapped in double quotes' {
            {Invoke-PackageCreation -InstallWelcomeParams "-CloseApps 'Pester'"} | Should -Throw
            Assert-MockCalled -CommandName Complete-Phase -Times 0
        }
        
        It 'Throw if UninstallWelcomeParams is wrapped in double quotes' {
            {Invoke-PackageCreation -UninstallWelcomeParams "-CloseApps 'Pester'"} | Should -Throw
            Assert-MockCalled -CommandName Complete-Phase -Times 0
        }
    }
}