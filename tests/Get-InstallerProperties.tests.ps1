$parent = Split-Path -Path $PSScriptRoot -Parent
$module = Split-Path -Path $parent -Leaf
Remove-Module $module -Force -ErrorAction SilentlyContinue
Import-Module $parent\Src\$module.psd1 -Force

Describe "$module - Get-InstallerProperties" {
    InModuleScope PackageAutomation {
        
        Mock Start-Phase
        Mock Complete-Phase
        Mock Start-FileDownload
        Mock Find-VersionInFileName -MockWith {'1.2.3.0'}
        Mock Get-MsiProperty -MockWith {[pscustomobject]@{ProductVersion = '1.2.3.0'}}
        Mock Get-FileMetadata -MockWith {[pscustomobject]@{Version = '';Manufacturer = ''}}
        Mock Test-Path {$true}

        Context 'MSIs' {
            
            $Results = Get-InstallerProperties -Path 'C:\pester.msi'
            
            It 'Gets MSI metadata if installer is an MSI' {
                Assert-MockCalled -CommandName Get-MsiProperty -Times 1 -Scope Context
                Assert-MockCalled -CommandName Get-FileMetadata -Times 0 -Scope Context
            }
            
            It 'Adds Version property to the results' {
                $Results.Version | Should -Be '1.2.3.0'
                $Results.ProductVersion | Should -Be '1.2.3.0'
            }
        }
        
        Context 'Other installers' {
            
            $Results = Get-InstallerProperties -Path 'C:\pester-1.2.3.0.exe'
            
            It 'Gets file metadata if installer is not an MSI' {
                Assert-MockCalled -CommandName Get-FileMetadata -Times 1 -Scope Context
                Assert-MockCalled -CommandName Get-MsiProperty -Times 0 -Scope Context
            }
            
            It 'Attempts to find version in filename if not in metadata' {
                Assert-MockCalled -CommandName Find-VersionInFileName -Times 1 -Scope Context
                $Results.Version | Should -Be '1.2.3.0'
            }

            It 'Throws an error if no version could be found' {
                Mock Find-VersionInFileName
                {Get-InstallerProperties -Path 'C:\pester-1.2.3.0.exe'} | Should -Throw
            }
        }

        Context 'Overrides' {
            It 'Correctly overrides MSI metadata if specified' {
                Mock Get-MsiProperty -MockWith {[pscustomoject]@{Version = '1.2';Manufacturer = 'Unknown'}}
                $Results = Get-InstallerProperties -Path 'C:\pester.exe' -Metadata {Version = '1.2.4.0'; Manufacturer = 'OverrideMSI'}
                
                $Results.Version | Should -Be '1.2.4.0'
                $Results.Manufacturer | Should -Be 'OverrideMSI'
            }

            It 'Correctly overrides file metadata if specified' {
                $Results = Get-InstallerProperties -Path 'C:\pester.exe' -Metadata {Version = '1.2.5.0'; Manufacturer = 'OverrideEXE'}

                $Results.Version | Should -Be '1.2.5.0'
                $Results.Manufacturer | Should -Be 'OverrideEXE'
            }
        }

    }
}