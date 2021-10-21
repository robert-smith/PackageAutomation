$parent = Split-Path -Path $PSScriptRoot -Parent
$module = Split-Path -Path $parent -Leaf
Remove-Module $module -Force -ErrorAction SilentlyContinue
Import-Module $parent\Src\$module.psd1 -Force

Describe "$module - Copy-ApplicationFiles" {
    InModuleScope PackageAutomation {
        
        # Define global variables that are used within PackageAutomation
        $Script:PackageConfigPath = 'TestDrive:\Extras'

        $Existing = Get-Content -Path $PSScriptRoot\DummyFiles\Deploy-Application.ps1 -Raw
        Mock New-Item
        Mock Move-Item
        Mock Copy-Item
        Mock Out-File
        Mock Start-Phase
        Mock Complete-Phase
        Mock Wait-FileLock
        Mock Write-Host
        Mock Get-ChildItem -ParameterFilter {$Path -eq 'TestDrive:\1.2.3.0'} -MockWith {@(
            [pscustomobject]@{Name = 'Deploy-Application.exe'}
            [pscustomobject]@{Name = 'Deploy-Application.exe.config'}
            [pscustomobject]@{Name = 'Deploy-Application.ps1'}
            [pscustomobject]@{Name = 'AppDeployToolkitBanner.png'}
            [pscustomobject]@{Name = 'AppDeployToolkitConfig.xml'}
            [pscustomobject]@{Name = 'AppDeployToolkitExtensions.ps1'}
            [pscustomobject]@{Name = 'AppDeployToolkitHelp.ps1'}
            [pscustomobject]@{Name = 'AppDeployToolkitLogo.ico'}
            [pscustomobject]@{Name = 'AppDeployToolkitMain.cs'}
            [pscustomobject]@{Name = 'AppDeployToolkitMain.ps1'}
        )}
		
        Context 'Status OK' {
            Mock Get-Content -ParameterFilter {$Path -like '*Deploy-Application.ps1'} -MockWith {$Existing}
            Mock Test-Path -ParameterFilter {$Path -like '*pester1.2.3.0.exe'} {$true}
            Mock Get-ChildItem -ParameterFilter {$Path -eq 'TestDrive:\Extras\Files'} -MockWith {@{Name = 'AutoHotKey.exe'}}
            Mock Test-Path -ParameterFilter {$Path -like "*AutoHotKey.exe"} -MockWith {$true}
            $CopySplat = @{
                AppName = 'PesterTest'
                RootPath = 'TestDrive:'
                Installer = 'pester1.2.3.0.exe'
                Version = '1.2.3.0'
                Manufacturer = 'Pester'
                InstallWelcomeParams = '-CloseApps "pester" -MinimizeWindows $false'
                PreInstall = ''
                Install = '        Start-Process -FilePath "pester1.2.3.0.exe" -ArgumentList ''/q'' -Wait'
                PostInstall = ''
                UninstallWelcomeParams = '-CloseApps "pester" -MinimizeWindows $false -CloseAppsCountdown 120'
                PreUninstall = ''
                Uninstall = '        Start-Process -FilePath ''pester1.2.3.0.exe'' -ArgumentList ''/qn /uninstall'' -Wait'
                PostUninstall = ''
            }
			Copy-ApplicationFiles @CopySplat

            $TestCases = @(
                @{File = 'Installer'}
                @{File = 'AutoHotKey.exe'}
                @{File = 'PowerShell ADT'}
                @{File = 'Deploy-Application.ps1'}
            )

            It 'Sets <File> to OK if detected at destination' -TestCases $TestCases {
                param ($File)
                Assert-MockCalled -CommandName Complete-Phase -ParameterFilter {$Details -contains "OK: $File"} -Times 1 -Exactly -Scope Context
            }
        }

        Context 'Status Success' {
            Mock Get-Content -ParameterFilter {$Path -like '*Deploy-Application.ps1'} -MockWith {}
            Mock Test-Path -ParameterFilter {$Path -like '*pester1.2.3.1.exe'} {$false}
            Mock Get-ChildItem -ParameterFilter {$Path -eq 'TestDrive:\Extras\Files'} -MockWith {@{Name = 'AutoHotKey.exe'; FullName = 'TestDrive:\Extras\Files\AutoHotKey.exe'}}
            Mock Test-Path -ParameterFilter {$Path -like "*AutoHotKey.exe"} -MockWith {$false}
            Mock Get-ChildItem -ParameterFilter {$Path -eq 'TestDrive:\1.2.3.1'} -MockWith {@(
                [pscustomobject]@{Name = 'Deploy-Application.exe.config'}
                [pscustomobject]@{Name = 'Deploy-Application.ps1'}
                [pscustomobject]@{Name = 'AppDeployToolkitBanner.png'}
                [pscustomobject]@{Name = 'AppDeployToolkitConfig.xml'}
                [pscustomobject]@{Name = 'AppDeployToolkitExtensions.ps1'}
                [pscustomobject]@{Name = 'AppDeployToolkitHelp.ps1'}
                [pscustomobject]@{Name = 'AppDeployToolkitLogo.ico'}
                [pscustomobject]@{Name = 'AppDeployToolkitMain.cs'}
                [pscustomobject]@{Name = 'AppDeployToolkitMain.ps1'}
            )}
            $CopySplat = @{
                AppName = 'PesterTest'
                RootPath = 'TestDrive:'
                Installer = 'pester1.2.3.1.exe'
                Version = '1.2.3.1'
                Manufacturer = 'Pester'
                InstallWelcomeParams = '-CloseApps "pester" -MinimizeWindows $false THIS IS DIFFERENT'
                PreInstall = ''
                Install = '        Start-Process -FilePath "pester1.2.3.1.exe" -ArgumentList ''/q'' -Wait'
                PostInstall = ''
                UninstallWelcomeParams = '-CloseApps "pester" -MinimizeWindows $false -CloseAppsCountdown 120'
                PreUninstall = ''
                Uninstall = '        Start-Process -FilePath ''pester1.2.3.1.exe'' -ArgumentList ''/qn /uninstall'' -Wait'
                PostUninstall = ''
            }
			Copy-ApplicationFiles @CopySplat

            $TestCases = @(
                @{File = 'Installer'}
                @{File = 'AutoHotKey.exe'}
                @{File = 'PowerShell ADT'}
                @{File = 'Deploy-Application.ps1'}
            )

            It 'Sets <File> to Success if detected at destination' -TestCases $TestCases {
                param ($File)
                Assert-MockCalled -CommandName Complete-Phase -ParameterFilter {$Details -contains "Success: $File"} -Times 1 -Exactly -Scope Context
            }

            It 'Sets Deploy-Application.ps1 to Success if script changes are detected' {
                Mock Get-Content -ParameterFilter {$Path -like '*Deploy-Application.ps1'} -MockWith {$Existing}
                Copy-ApplicationFiles @CopySplat
                Assert-MockCalled -CommandName Complete-Phase -ParameterFilter {$Details -contains "Success: Deploy-Application.ps1"} -Times 1 -Exactly -Scope It
            }
        }

    }
}