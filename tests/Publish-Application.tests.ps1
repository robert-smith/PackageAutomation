$parent = Split-Path -Path $PSScriptRoot -Parent
$module = Split-Path -Path $parent -Leaf
Remove-Module $module -Force -ErrorAction SilentlyContinue
Import-Module $parent\Src\$module.psd1 -Force
$CMDlls = Get-ChildItem -Path "$PSScriptRoot\ConfigurationManager\*.dll"
foreach ($Dll in $CMDlls) {
    [Reflection.Assembly]::LoadFile($Dll.FullName) | out-null
}
Import-Module "$PSScriptRoot\ConfigurationManager\ConfigurationManager.psd1" -Force -Scope Global -ErrorAction SilentlyContinue

Describe "$module - Publish-Application" {
    InModuleScope PackageAutomation {
        
        Mock Write-Host
        Mock Wait-FileLock
        Mock Resolve-Path -MockWith {'\\contoso.com\dfsshare\Packages\Pester\icon.png'} -ParameterFilter {$Path -match 'icon'}
        
        Context Logic {
            
            $Address = 'https://mock.me'
            $Dest = 'TestDrive:\Pester'
            $Ver = '1.8.3.0'
            $File = "pester-$Ver.msi"
            $ProdCode = '{b1ac29e6-6fc4-43c8-8d00-6c811e167d8a}'
            
            $Properties = [PSCustomObject]@{
                Version = $Ver
                Manufacturer = 'Pester Inc.'
                ProductCode = $ProdCode
                ProductVersion = $Ver
            }
            
            $Latest = [PSCustomObject]@{
                Name = $File
                FullName = "$Dest\$File"
            }
            
            function New-CMApplicationDeployment {}

            Mock Get-InstallerProperties {$Properties}
            Mock Get-RedirectURL {"https://thisdoesnotexist.com/$File"}
            Mock Save-LatestVersion -ParameterFilter {$URL -eq $Address} -MockWith {$Latest}
            Mock New-Application
            Mock Start-FileDownload
            Mock Copy-ApplicationFiles
            Mock Connect-SCCM
            Mock New-CMApplicationDeployment
            
            Application Pester {
                URL = $Address
                Destination = $Dest
                InstallWelcomeParams = '-CloseApps "code=Visual Studio Code" -CloseAppsCountdown 120 -PersistPrompt -MinimizeWindows $false'
                UninstallWelcomeParams = '-CloseApps "code=Visual Studio Code" -CloseAppsCountdown 120 -PersistPrompt -MinimizeWindows $false'
                Install = {Execute-MSI -Action Install -Path $PSScriptRoot\Files\%%INSTALLERNAME%%}
                Uninstall = {Execute-MSI -Action Uninstall -Path '%%PRODUCTCODE%%'}
                SupersedeLastVersion = {
                    Enabled = $true
                    Uninstall = $true
                }
                Deployments = {
                        Deploy {
                            CollectionName = '%%APPNAME%%'
                            DeployPurpose = 'Required'
                            OverrideServiceWindow = $true
                            RebootOutsideServiceWindow = $false
                        }
                    }
                DetectionRules = {
                    RegistryValue {
                        Hive = 'LocalMachine'
                        KeyName = "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\%%ProductCode%%"
                        ValueName = 'ProductVersion'
                        PropertyType = 'Version'
                        ExpressionOperator = 'GreaterEquals'
                        ExpectedValue = '%%VERSION%%'
                    }
                    File {
                        FileName = 'Pester.exe'
                        Path = '%PROGRAMFILES%\Pester'
                    }
                }
            }
    
            It 'Passes correct URL and Destination to Save-LatestVersion' {
                Assert-MockCalled -CommandName Save-LatestVersion -Times 1 -Scope Context -ParameterFilter {
                    $URL -eq $Address -and
                    $Destination -eq $Dest
                }
            }

            It 'Passes expanded strings to Copy-ApplicationFiles' {
                Assert-MockCalled -CommandName Copy-ApplicationFiles -Times 1 -Scope Context -ParameterFilter {
                    $Install -eq "Execute-MSI -Action Install -Path `$PSScriptRoot\Files\$File" -and
                    $Uninstall -eq "Execute-MSI -Action Uninstall -Path '$ProdCode'"
                }
            }

            It 'Passes correct values to New-Application' {
                Assert-MockCalled -CommandName New-Application -Times 1 -Scope Context -ParameterFilter {
                    $ContentPath -eq "$Dest\$Ver" -and
                    $Name -eq 'Pester' -and
                    $Manufacturer -eq 'Pester Inc.' -and
                    $SupersedeLastVersion.Enabled -eq $true -and
                    $SupersedeLastVersion.Uninstall -eq $true -and
                    $DetectionRule[0].Constant.Value -eq $Ver -and
                    $DetectionRule[1].MethodType -eq 'Count' -and
                    $DetectionRule[1].Setting.FileOrFolderName -eq 'Pester.exe'
                }
            }

            It 'Sets detection method to value for File if the value parameters are set' {
                Application Pester {
                    URL = $Address
                    Destination = $Dest
                    InstallWelcomeParams = '-CloseApps "code=Visual Studio Code" -CloseAppsCountdown 120 -PersistPrompt -MinimizeWindows $false'
                    UninstallWelcomeParams = '-CloseApps "code=Visual Studio Code" -CloseAppsCountdown 120 -PersistPrompt -MinimizeWindows $false'
                    Install = {Execute-MSI -Action Install -Path $PSScriptRoot\Files\%%INSTALLERNAME%%}
                    Uninstall = {Execute-MSI -Action Uninstall -Path '%%PRODUCTCODE%%'}
                    SupersedeLastVersion = {
                        Enabled = $true
                        Uninstall = $true
                    }
                    Deployments = {
                        Deploy {
                            CollectionName = '%%APPNAME%%'
                            DeployPurpose = 'Required'
                            OverrideServiceWindow = $true
                            RebootOutsideServiceWindow = $false
                        }
                    }
                    DetectionRules = {
                        RegistryValue {
                            Hive = 'LocalMachine'
                            KeyName = "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\%%ProductCode%%"
                            ValueName = 'ProductVersion'
                            PropertyType = 'Version'
                            ExpressionOperator = 'GreaterEquals'
                            ExpectedValue = '%%VERSION%%'
                        }
                        File {
                            FileName = 'Pester.exe'
                            Path = '%PROGRAMFILES%\Pester'
                            PropertyType = 'Version'
                            ExpressionOperator = 'GreaterEquals'
                            ExpectedValue = '%%VERSION%%'
                        }
                    }
                }

                Assert-MockCalled -CommandName New-Application -Times 1 -Scope It -ParameterFilter {
                    $ContentPath -eq "$Dest\$Ver" -and
                    $Name -eq 'Pester' -and
                    $Manufacturer -eq 'Pester Inc.' -and
                    $SupersedeLastVersion.Enabled -eq $true -and
                    $SupersedeLastVersion.Uninstall -eq $true -and
                    $DetectionRule[1].MethodType -eq 'Value' -and
                    $DetectionRule[1].Constant.Value -eq $Ver -and
                    $DetectionRule[1].Setting.FileOrFolderName -eq 'Pester.exe'
                }
            }

            It 'Correctly extract version from file name' {
                # Unmock New-Application
                Remove-Item -Path Alias:\New-Application -Force
                Remove-Item -Path Alias:\Get-InstallerProperties -Force
                
                function Get-CMApplication {}
                function New-CMApplication {
                    param (
                        $Name,
                        $Publisher,
                        $SoftwareVersion,
                        $LocalizedName,
                        $IconLocationFile
                    )
                }
                
                $Version = '1.2.3.0'
                $Latest = [PSCustomObject]@{
                    Name = "PackageTest$Version.exe"
                    FullName = "$Dest\PackageTest1.2.3.0.exe"
                }
                
                Mock Save-LatestVersion -MockWith {$Latest}
                Mock New-CMApplication
                function Get-FileMetadata {}
                Mock Get-FileMetadata -MockWith {[pscustomobject]@{
                    Version = $null
                    Manufacturer = $null
                }}

                $VersionTest = Application Pester {
                    URL = $Address
                    Destination = $Dest
                    Metadata = {
                        Manufacturer = 'Pester'
                    }
                    InstallWelcomeParams = '-CloseApps "code=Visual Studio Code" -CloseAppsCountdown 120 -PersistPrompt -MinimizeWindows $false'
                    UninstallWelcomeParams = '-CloseApps "code=Visual Studio Code" -CloseAppsCountdown 120 -PersistPrompt -MinimizeWindows $false'
                    Install = {Execute-MSI -Action Install -Path $PSScriptRoot\Files\%%INSTALLERNAME%%}
                    Uninstall = {Execute-MSI -Action Uninstall -Path '%%PRODUCTCODE%%'}
                    SupersedeLastVersion = {
                        Enabled = $true
                        Uninstall = $true
                    }
                    Deployments = {
                        Deploy {
                            CollectionName = '%%APPNAME%%'
                            DeployPurpose = 'Required'
                            OverrideServiceWindow = $true
                            RebootOutsideServiceWindow = $false
                        }
                    }
                    DetectionRules = {
                        File {
                            FileName = 'Pester.exe'
                            Path = '%PROGRAMFILES%\Pester'
                            PropertyType = 'Version'
                            ExpressionOperator = 'GreaterEquals'
                            ExpectedValue = '%%VERSION%%'
                        }
                    }
                }

                Assert-MockCalled -CommandName New-CMApplication -Scope It -Times 1 -Exactly -ParameterFilter {
                    $SoftwareVersion -eq $Version
                }

            }
        }

        Context Phases {
            
            $AppName = 'Pester'
            $Address = 'https://thisdoesnotexist.com/latest'
            $Dest = 'TestDrive:\Pester'
            $Ver = '1.8.3.0'
            $File = "$AppName-$Ver.msi"
            $ProdCode = '{b1ac29e6-6fc4-43c8-8d00-6c811e167d8a}'
            
            $Properties = [PSCustomObject]@{
                Version = $Ver
                Manufacturer = 'Pester Inc.'
                ProductCode = $ProdCode
                ProductVersion = $Ver
            }
            
            $Latest = [PSCustomObject]@{
                Name = $File
                FullName = "$Dest\$File"
            }

            $MockApps = @(
                [PSCustomObject]@{
                    IsSuperseded = $false
                    SoftwareVersion = '1.3.8'
                }
                [PSCustomObject]@{
                    IsSuperseded = $false
                    SoftwareVersion = '1.3.7'
                }
            )

            # Mocking certain cmdlets doesn't work easily if their parameters are looking for
            # specific objects. We'll just create blank functions with the same names then mock those.
            function Get-CMDeviceCollection {param($Name)}
            function New-CMDeviceCollection {}
            function Get-CMDistributionStatus {}
            function Start-CMContentDistribution {param($InputObject)}
            function Get-CMApplicationDeployment {param($Name)}
            function New-CMApplicationDeployment {param($Name)}
            function Get-CMApplication {param($Name)}
            function New-CMApplication {}
            function Get-CMDeploymentType {param($ApplicationName)}
            function Add-CMScriptDeploymentType {param($DeploymentTypeName)}
            function Add-CMDeploymentTypeSupersedence {}
            function Set-CMDeploymentType {}
            function Move-CMObject {}

            function New-CMDeploymentTypeDependencyGroup {param($GroupName, $InputObject)}

            function Add-CMDeploymentTypeDependency {param($IsAutoInstall, $DeploymentTypeDependency, $InputObject)}
            
            Mock Get-CMApplication -ParameterFilter {$Name -ne "Pester"}
            Mock Get-CMApplication -ParameterFilter {$Name -eq 'Pester*'} {$MockApps}
            Mock New-CMApplication {$MockApps}
            Mock Get-CMDeploymentType
            #Mock Add-CMScriptDeploymentType
            Mock Set-CMDeploymentType
            Mock Add-CMDeploymentTypeSupersedence
            Mock Get-CMApplicationDeployment
            Mock New-CMApplicationDeployment
            Mock Get-RedirectURL {"https://thisdoesnotexist.com/$File"}
            Mock Save-LatestVersion -ParameterFilter {$URL -eq $Address} -MockWith {$Latest}
            Mock Move-CMObject

            Context 'New application with supersedence' {

                Mock Get-InstallerProperties {$Properties}
                Mock Copy-ApplicationFiles
                Mock Connect-SCCM
                Mock Set-Supersedence {[PSCustomObject]@{
                    Status = 'Success'
                    Details = 'Uninstall mode set to true'
                }}

                $NewSupersedeResults = Application $AppName {
                    URL = $Address
                    Destination = $Dest
                    InstallWelcomeParams = '-CloseApps "code=Visual Studio Code" -CloseAppsCountdown 120 -PersistPrompt -MinimizeWindows $false'
                    UninstallWelcomeParams = '-CloseApps "code=Visual Studio Code" -CloseAppsCountdown 120 -PersistPrompt -MinimizeWindows $false'
                    Install = {Execute-MSI -Action Install -Path $PSScriptRoot\Files\%%INSTALLERNAME%%}
                    Uninstall = {Execute-MSI -Action Uninstall -Path '%%PRODUCTCODE%%'}
                    SupersedeLastVersion = {
                        Enabled = $true
                        Uninstall = $true
                    }
                    Deployments = {
                        Deploy {
                            CollectionName = '%%APPNAME%%'
                            DeployPurpose = 'Required'
                            OverrideServiceWindow = $true
                            RebootOutsideServiceWindow = $false
                        }
                    }
                    DetectionRules = {
                        RegistryValue {
                            Hive = 'LocalMachine'
                            KeyName = "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\%%ProductCode%%"
                            ValueName = 'ProductVersion'
                            PropertyType = 'Version'
                            ExpressionOperator = 'GreaterEquals'
                            ExpectedValue = '%%VERSION%%'
                        }
                        File {
                            FileName = 'Pester.exe'
                            Path = '%PROGRAMFILES%\Pester'
                        }
                    }
                }

                $Cases = @(
                    @{Name = 'NewApp'},
                    @{Name = 'DeploymentType'},
                    @{Name = 'Supersedence'},
                    @{Name = 'Distribute'},
                    @{Name = 'Deploy'}
                )

                It 'Sets <Name> to "Success"' -TestCases $Cases {
                    param ($Name)
                    $NewSupersedeResults.Phases.Where{$_.Name -eq $Name}.Status | Should -BeLike 'Success*'
                }
            }

            Context 'New application without supersedence' {

                Mock Get-InstallerProperties {$Properties}
                Mock Copy-ApplicationFiles
                Mock Connect-SCCM

                $NewNoSupersedeResults = Application $AppName {
                    URL = $Address
                    Destination = $Dest
                    InstallWelcomeParams = '-CloseApps "code=Visual Studio Code" -CloseAppsCountdown 120 -PersistPrompt -MinimizeWindows $false'
                    UninstallWelcomeParams = '-CloseApps "code=Visual Studio Code" -CloseAppsCountdown 120 -PersistPrompt -MinimizeWindows $false'
                    Install = {Execute-MSI -Action Install -Path $PSScriptRoot\Files\%%INSTALLERNAME%%}
                    Uninstall = {Execute-MSI -Action Uninstall -Path '%%PRODUCTCODE%%'}
                    SupersedeLastVersion = {
                        Enabled = $false
                    }
                    Deployments = {
                        Deploy {
                            CollectionName = '%%APPNAME%%'
                            DeployPurpose = 'Required'
                            OverrideServiceWindow = $true
                            RebootOutsideServiceWindow = $false
                        }
                    }
                    DetectionRules = {
                        RegistryValue {
                            Hive = 'LocalMachine'
                            KeyName = "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\%%ProductCode%%"
                            ValueName = 'ProductVersion'
                            PropertyType = 'Version'
                            ExpressionOperator = 'GreaterEquals'
                            ExpectedValue = '%%VERSION%%'
                        }
                        File {
                            FileName = 'Pester.exe'
                            Path = '%PROGRAMFILES%\Pester'
                        }
                    }
                }

                $Cases = @(
                    @{Name = 'NewApp'; Status = 'Success*'},
                    @{Name = 'DeploymentType'; Status = 'Success*'},
                    @{Name = 'Supersedence'; Status = 'Not run'},
                    @{Name = 'Distribute'; Status = 'Success*'},
                    @{Name = 'Deploy'; Status = 'Success*'}
                )

                It 'Sets <Name> to "<Status>"' -TestCases $Cases {
                    param ($Name, $Status)
                    $NewNoSupersedeResults.Phases.Where{$_.Name -eq $Name}.Status | Should -BeLike $Status
                }
            } # Context New app w/o supersede

            Context 'App already exists' {

                $Superseded = @(
                    [PSCustomObject]@{
                        IsSuperseded = $false
                        SoftwareVersion = '1.3.8'
                    }
                    [PSCustomObject]@{
                        IsSuperseded = $true
                        SoftwareVersion = '1.3.7'
                    }
                )

                Mock Get-InstallerProperties {$Properties}
                Mock Copy-ApplicationFiles
                Mock Connect-SCCM
                Mock Get-CMApplication -ParameterFilter {$Name -ne "Pester"} {$true}
                Mock Get-CMApplication -ParameterFilter {$Name -eq 'Pester*'} {$Superseded}
                Mock Get-CMDeploymentType {$true}
                Mock Get-CMDeviceCollection {$true}
                Mock Get-CMDistributionStatus {[PSCustomObject]@{
                    Targeted = 1
                }}
                Mock Get-CMApplicationDeployment {[PSCustomObject]@{
                    CollectionName = 'Pester'
                }}
                Mock Set-Supersedence {[PSCustomObject]@{
                    Status = 'OK'
                }}

                $ExistsResults = Application $AppName {
                    URL = $Address
                    Destination = $Dest
                    InstallWelcomeParams = '-CloseApps "code=Visual Studio Code" -CloseAppsCountdown 120 -PersistPrompt -MinimizeWindows $false'
                    UninstallWelcomeParams = '-CloseApps "code=Visual Studio Code" -CloseAppsCountdown 120 -PersistPrompt -MinimizeWindows $false'
                    Install = {Execute-MSI -Action Install -Path $PSScriptRoot\Files\%%INSTALLERNAME%%}
                    Uninstall = {Execute-MSI -Action Uninstall -Path '%%PRODUCTCODE%%'}
                    SupersedeLastVersion = {
                        Enabled = $true
                        Uninstall = $true
                    }
                    Deployments = {
                        Deploy {
                            CollectionName = '%%APPNAME%%'
                            DeployPurpose = 'Required'
                            OverrideServiceWindow = $true
                            RebootOutsideServiceWindow = $false
                        }
                    }
                    DetectionRules = {
                        RegistryValue {
                            Hive = 'LocalMachine'
                            KeyName = "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\%%ProductCode%%"
                            ValueName = 'ProductVersion'
                            PropertyType = 'Version'
                            ExpressionOperator = 'GreaterEquals'
                            ExpectedValue = '%%VERSION%%'
                        }
                        File {
                            FileName = 'Pester.exe'
                            Path = '%PROGRAMFILES%\Pester'
                        }
                    }
                }

                $Cases = @(
                    @{Name = 'NewApp'; Status = 'OK'},
                    @{Name = 'DeploymentType'; Status = 'OK'},
                    @{Name = 'Supersedence'; Status = 'OK'},
                    @{Name = 'Distribute'; Status = 'OK'},
                    @{Name = 'Deploy'; Status = "OK: Install Required -> $AppName"}
                )

                It 'Sets <Name> to "<Status>"' -TestCases $Cases {
                    param ($Name, $Status)
                    $ExistsResults.Phases.Where{$_.Name -eq $Name}.Status | Should -Be $Status
                }
            } # Context app exists

            Context 'Initialize' {

                $InitializeFail = Application $AppName {
                    URL = 'https://donotmock.me/latest'
                    Destination = $Dest
                    InstallWelcomeParams = '-CloseApps "code=Visual Studio Code" -CloseAppsCountdown 120 -PersistPrompt -MinimizeWindows $false'
                    UninstallWelcomeParams = '-CloseApps "code=Visual Studio Code" -CloseAppsCountdown 120 -PersistPrompt -MinimizeWindows $false'
                    Install = {Execute-MSI -Action Install -Path $PSScriptRoot\Files\%%INSTALLERNAME%%}
                    Uninstall = {Execute-MSI -Action Uninstall -Path '%%PRODUCTCODE%%'}
                    SupersedeLastVersion = $true
                    Deployments = {
                        Deploy {
                            CollectionName = '%%APPNAME%%'
                            DeployPurpose = 'Required'
                            OverrideServiceWindow = $true
                            RebootOutsideServiceWindow = $false
                        }
                    }
                    DetectionRules = {
                        RegistryValue {
                            Hive = 'LocalMachine'
                            KeyName = "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\%%ProductCode%%"
                            ValueName = 'ProductVersion'
                            PropertyType = 'Version'
                            ExpressionOperator = 'GreaterEquals'
                            ExpectedValue = '%%VERSION%%'
                        }
                        File {
                            FileName = 'Pester.exe'
                            Path = '%PROGRAMFILES%\Pester'
                        }
                    }
                }
                It 'Fails if a parameter is not set correctly' {
                    $InitializeFail.Phases.Where{$_.Name -eq 'Initialize'}.Status | Should -BeLike "Failed*Cannot process argument transformation on parameter 'SupersedeLastVersion'*"
                }
            } # Context Initialize

            Context 'GetURL' {

                $ErrorMessage = 'Some error!'
                Mock Get-RedirectURL {throw $ErrorMessage}

                $URLFail = Application $AppName {
                    URL = 'https://donotmock.me/latest'
                    Destination = $Dest
                    InstallWelcomeParams = '-CloseApps "code=Visual Studio Code" -CloseAppsCountdown 120 -PersistPrompt -MinimizeWindows $false'
                    UninstallWelcomeParams = '-CloseApps "code=Visual Studio Code" -CloseAppsCountdown 120 -PersistPrompt -MinimizeWindows $false'
                    Install = {Execute-MSI -Action Install -Path $PSScriptRoot\Files\%%INSTALLERNAME%%}
                    Uninstall = {Execute-MSI -Action Uninstall -Path '%%PRODUCTCODE%%'}
                    SupersedeLastVersion = {
                        Enabled = $true
                        Uninstall = $true
                    }
                    Deployments = {
                        Deploy {
                            CollectionName = '%%APPNAME%%'
                            DeployPurpose = 'Required'
                            OverrideServiceWindow = $true
                            RebootOutsideServiceWindow = $false
                        }
                    }
                    DetectionRules = {
                        RegistryValue {
                            Hive = 'LocalMachine'
                            KeyName = "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\%%ProductCode%%"
                            ValueName = 'ProductVersion'
                            PropertyType = 'Version'
                            ExpressionOperator = 'GreaterEquals'
                            ExpectedValue = '%%VERSION%%'
                        }
                        File {
                            FileName = 'Pester.exe'
                            Path = '%PROGRAMFILES%\Pester'
                        }
                    }
                }

                It 'Sets GetURL phase phase to Failed on error on error' {
                    $URLFail.Phases.Where{$_.Name -eq 'GetURL'}.Status | Should -BeLike 'Failed*'
                }

                It 'Includes error message with "Failed" status' {
                    $URLFail.Phases.Where{$_.Name -eq 'GetURL'}.Status | Should -BeLike "*$ErrorMessage*"
                }
            } # Context app exists

            Context 'CheckVersion' {

                $ErrorMessage = 'Some error!'
                Mock Get-ChildItem {throw $ErrorMessage}

                $CheckFail = Application $AppName {
                    URL = 'https://donotmock.me/latest'
                    Destination = 'TestDrive:\'
                    InstallWelcomeParams = '-CloseApps "code=Visual Studio Code" -CloseAppsCountdown 120 -PersistPrompt -MinimizeWindows $false'
                    UninstallWelcomeParams = '-CloseApps "code=Visual Studio Code" -CloseAppsCountdown 120 -PersistPrompt -MinimizeWindows $false'
                    Install = {Execute-MSI -Action Install -Path $PSScriptRoot\Files\%%INSTALLERNAME%%}
                    Uninstall = {Execute-MSI -Action Uninstall -Path '%%PRODUCTCODE%%'}
                    SupersedeLastVersion = {
                        Enabled = $true
                        Uninstall = $true
                    }
                    Deployments = {
                        Deploy {
                            CollectionName = '%%APPNAME%%'
                            DeployPurpose = 'Required'
                            OverrideServiceWindow = $true
                            RebootOutsideServiceWindow = $false
                        }
                    }
                    DetectionRules = {
                        RegistryValue {
                            Hive = 'LocalMachine'
                            KeyName = "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\%%ProductCode%%"
                            ValueName = 'ProductVersion'
                            PropertyType = 'Version'
                            ExpressionOperator = 'GreaterEquals'
                            ExpectedValue = '%%VERSION%%'
                        }
                        File {
                            FileName = 'Pester.exe'
                            Path = '%PROGRAMFILES%\Pester'
                        }
                    }
                }

                It 'Sets CheckVersion phase phase to Failed on error on error' {
                    $CheckFail.Phases.Where{$_.Name -eq 'CheckVersion'}.Status | Should -BeLike 'Failed*'
                }

                It 'Includes error message with "Failed" status' {
                    $CheckFail.Phases.Where{$_.Name -eq 'CheckVersion'}.Status | Should -BeLike "*$ErrorMessage*"
                }

            } # Context app exists

            Context 'Download' {

                $ErrorMessage = 'Some error!'
                Mock New-Object -ParameterFilter {$TypeName -eq 'System.Net.WebClient'} {throw $ErrorMessage}

                $DownloadFail = Application $AppName {
                    URL = 'https://donotmock.me/latest'
                    Destination = $Dest
                    InstallWelcomeParams = '-CloseApps "code=Visual Studio Code" -CloseAppsCountdown 120 -PersistPrompt -MinimizeWindows $false'
                    UninstallWelcomeParams = '-CloseApps "code=Visual Studio Code" -CloseAppsCountdown 120 -PersistPrompt -MinimizeWindows $false'
                    Install = {Execute-MSI -Action Install -Path $PSScriptRoot\Files\%%INSTALLERNAME%%}
                    Uninstall = {Execute-MSI -Action Uninstall -Path '%%PRODUCTCODE%%'}
                    SupersedeLastVersion = {
                        Enabled = $true
                        Uninstall = $true
                    }
                    Deployments = {
                        Deploy {
                            CollectionName = '%%APPNAME%%'
                            DeployPurpose = 'Required'
                            OverrideServiceWindow = $true
                            RebootOutsideServiceWindow = $false
                        }
                    }
                    DetectionRules = {
                        RegistryValue {
                            Hive = 'LocalMachine'
                            KeyName = "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\%%ProductCode%%"
                            ValueName = 'ProductVersion'
                            PropertyType = 'Version'
                            ExpressionOperator = 'GreaterEquals'
                            ExpectedValue = '%%VERSION%%'
                        }
                        File {
                            FileName = 'Pester.exe'
                            Path = '%PROGRAMFILES%\Pester'
                        }
                    }
                }

                It 'Sets Download phase phase to Failed on error on error' {
                    $DownloadFail.Phases.Where{$_.Name -eq 'Download'}.Status | Should -BeLike 'Failed*'
                }

                It 'Includes error message with "Failed" status' {
                    $DownloadFail.Phases.Where{$_.Name -eq 'Download'}.Status | Should -BeLike "*$ErrorMessage*"
                }

                It 'Fails if URL does not end with .exe or .msi and includes bad URL in message' {
                    $Site = 'https://noinstallfile.com'
                    Mock Get-RedirectURL -ParameterFilter {$URL -eq 'CustomMock'} {$Site}

                    $DownloadFail = Application $AppName {
                        URL = 'CustomMock'
                        Destination = $Dest
                        InstallWelcomeParams = '-CloseApps "code=Visual Studio Code" -CloseAppsCountdown 120 -PersistPrompt -MinimizeWindows $false'
                        UninstallWelcomeParams = '-CloseApps "code=Visual Studio Code" -CloseAppsCountdown 120 -PersistPrompt -MinimizeWindows $false'
                        Install = {Execute-MSI -Action Install -Path $PSScriptRoot\Files\%%INSTALLERNAME%%}
                        Uninstall = {Execute-MSI -Action Uninstall -Path '%%PRODUCTCODE%%'}
                        SupersedeLastVersion = {
                            Enabled = $true
                            Uninstall = $true
                        }
                        Deployments = {
                        Deploy {
                            CollectionName = '%%APPNAME%%'
                            DeployPurpose = 'Required'
                            OverrideServiceWindow = $true
                            RebootOutsideServiceWindow = $false
                        }
                    }
                        DetectionRules = {
                            RegistryValue {
                                Hive = 'LocalMachine'
                                KeyName = "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\%%ProductCode%%"
                                ValueName = 'ProductVersion'
                                PropertyType = 'Version'
                                ExpressionOperator = 'GreaterEquals'
                                ExpectedValue = '%%VERSION%%'
                            }
                            File {
                                FileName = 'Pester.exe'
                                Path = '%PROGRAMFILES%\Pester'
                            }
                        }
                    }
                    
                    $DownloadFail.Phases.Where{$_.Name -eq 'Download'}.Status | Should -BeLike "Failed*$Site*"
                }
            } # Context app exists

            Context 'MSIProps' {

                Mock Save-LatestVersion {$Latest}

                $PropFail = Application $AppName {
                    URL = $Address
                    Destination = $Dest
                    InstallWelcomeParams = '-CloseApps "code=Visual Studio Code" -CloseAppsCountdown 120 -PersistPrompt -MinimizeWindows $false'
                    UninstallWelcomeParams = '-CloseApps "code=Visual Studio Code" -CloseAppsCountdown 120 -PersistPrompt -MinimizeWindows $false'
                    Install = {Execute-MSI -Action Install -Path $PSScriptRoot\Files\%%INSTALLERNAME%%}
                    Uninstall = {Execute-MSI -Action Uninstall -Path '%%PRODUCTCODE%%'}
                    SupersedeLastVersion = {
                        Enabled = $true
                        Uninstall = $true
                    }
                    Deployments = {
                        Deploy {
                            CollectionName = '%%APPNAME%%'
                            DeployPurpose = 'Required'
                            OverrideServiceWindow = $true
                            RebootOutsideServiceWindow = $false
                        }
                    }
                    DetectionRules = {
                        RegistryValue {
                            Hive = 'LocalMachine'
                            KeyName = "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\%%ProductCode%%"
                            ValueName = 'ProductVersion'
                            PropertyType = 'Version'
                            ExpressionOperator = 'GreaterEquals'
                            ExpectedValue = '%%VERSION%%'
                        }
                        File {
                            FileName = 'Pester.exe'
                            Path = '%PROGRAMFILES%\Pester'
                        }
                    }
                }

                It 'Sets MSIProps phase to Failed on error' {
                    $PropFail.Phases.Where{$_.Name -eq 'MSIProps'}.Status | Should -BeLike 'Failed*'
                }

                It 'Includes error message with "Failed" status' {
                    $PropFail.Phases.Where{$_.Name -ne 'MSIProps'}.Status | Should -Not -BeLike 'Failed*'
                }
            } # Context app exists

            Context 'CopyFiles' {

                $ErrorMessage = 'Some error!'
                Mock Move-Item {throw $ErrorMessage}
                Mock Get-InstallerProperties {$Properties}

                $CopyFail = Application $AppName {
                    URL = $Address
                    Destination = $Dest
                    InstallWelcomeParams = '-CloseApps "code=Visual Studio Code" -CloseAppsCountdown 120 -PersistPrompt -MinimizeWindows $false'
                    UninstallWelcomeParams = '-CloseApps "code=Visual Studio Code" -CloseAppsCountdown 120 -PersistPrompt -MinimizeWindows $false'
                    Install = {Execute-MSI -Action Install -Path $PSScriptRoot\Files\%%INSTALLERNAME%%}
                    Uninstall = {Execute-MSI -Action Uninstall -Path '%%PRODUCTCODE%%'}
                    SupersedeLastVersion = {
                        Enabled = $true
                        Uninstall = $true
                    }
                    Deployments = {
                        Deploy {
                            CollectionName = '%%APPNAME%%'
                            DeployPurpose = 'Required'
                            OverrideServiceWindow = $true
                            RebootOutsideServiceWindow = $false
                        }
                    }
                    DetectionRules = {
                        RegistryValue {
                            Hive = 'LocalMachine'
                            KeyName = "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\%%ProductCode%%"
                            ValueName = 'ProductVersion'
                            PropertyType = 'Version'
                            ExpressionOperator = 'GreaterEquals'
                            ExpectedValue = '%%VERSION%%'
                        }
                        File {
                            FileName = 'Pester.exe'
                            Path = '%PROGRAMFILES%\Pester'
                        }
                    }
                }

                It 'Sets CopyFiles phase to Failed on error' {
                    $CopyFail.Phases.Where{$_.Name -eq 'CopyFiles'}.Status | Should -BeLike 'Failed*'
                }

                It 'Includes error message with "Failed" status' {
                    $CopyFail.Phases.Where{$_.Name -eq 'CopyFiles'}.Status | Should -BeLike "*$ErrorMessage*"
                }
            } # Context app exists

            Context 'ConnectSCCM' {

                $ErrorMessage = 'Some error!'
                Mock Get-InstallerProperties {$Properties}
                Mock Copy-ApplicationFiles
                Mock Import-Module
                Mock Get-CimInstance
                Mock New-PSDrive {throw $ErrorMessage}

                $ConnectFail = Application $AppName {
                    URL = $Address
                    Destination = $Dest
                    InstallWelcomeParams = '-CloseApps "code=Visual Studio Code" -CloseAppsCountdown 120 -PersistPrompt -MinimizeWindows $false'
                    UninstallWelcomeParams = '-CloseApps "code=Visual Studio Code" -CloseAppsCountdown 120 -PersistPrompt -MinimizeWindows $false'
                    Install = {Execute-MSI -Action Install -Path $PSScriptRoot\Files\%%INSTALLERNAME%%}
                    Uninstall = {Execute-MSI -Action Uninstall -Path '%%PRODUCTCODE%%'}
                    SupersedeLastVersion = {
                        Enabled = $true
                        Uninstall = $true
                    }
                    Deployments = {
                        Deploy {
                            CollectionName = '%%APPNAME%%'
                            DeployPurpose = 'Required'
                            OverrideServiceWindow = $true
                            RebootOutsideServiceWindow = $false
                        }
                    }
                    DetectionRules = {
                        RegistryValue {
                            Hive = 'LocalMachine'
                            KeyName = "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\%%ProductCode%%"
                            ValueName = 'ProductVersion'
                            PropertyType = 'Version'
                            ExpressionOperator = 'GreaterEquals'
                            ExpectedValue = '%%VERSION%%'
                        }
                        File {
                            FileName = 'Pester.exe'
                            Path = '%PROGRAMFILES%\Pester'
                        }
                    }
                }

                It 'Sets ConnectSCCM phase to Failed on error' {
                    $ConnectFail.Phases.Where{$_.Name -eq 'ConnectSCCM'}.Status | Should -BeLike 'Failed*'
                }

                It 'Includes error message with "Failed" status' {
                    $ConnectFail.Phases.Where{$_.Name -eq 'ConnectSCCM'}.Status | Should -BeLike "*$ErrorMessage*"
                }
            } # Context app exists

            Context 'DetectionRules' {

                $ErrorMessage = 'Some error!'
                Mock Get-InstallerProperties {$Properties}
                Mock Copy-ApplicationFiles
                Mock Connect-SCCM

                $DetectFail = Application $AppName {
                    URL = $Address
                    Destination = $Dest
                    InstallWelcomeParams = '-CloseApps "code=Visual Studio Code" -CloseAppsCountdown 120 -PersistPrompt -MinimizeWindows $false'
                    UninstallWelcomeParams = '-CloseApps "code=Visual Studio Code" -CloseAppsCountdown 120 -PersistPrompt -MinimizeWindows $false'
                    Install = {Execute-MSI -Action Install -Path $PSScriptRoot\Files\%%INSTALLERNAME%%}
                    Uninstall = {Execute-MSI -Action Uninstall -Path '%%PRODUCTCODE%%'}
                    SupersedeLastVersion = {
                        Enabled = $true
                        Uninstall = $true
                    }
                    Deployments = {
                        Deploy {
                            CollectionName = '%%APPNAME%%'
                            DeployPurpose = 'Required'
                            OverrideServiceWindow = $true
                            RebootOutsideServiceWindow = $false
                        }
                    }
                    DetectionRules = {
                        DoesNotExist {
                            Hive = 'LocalMachine'
                            KeyName = "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\%%ProductCode%%"
                            ValueName = 'ProductVersion'
                            PropertyType = 'Version'
                            ExpressionOperator = 'GreaterEquals'
                            ExpectedValue = '%%VERSION%%'
                        }
                    }
                }

                It 'Sets DetectionRules phase to Failed on error' {
                    $DetectFail.Phases.Where{$_.Name -eq 'DetectionRules'}.Status | Should -BeLike 'Failed*'
                }

                It 'Includes error message with "Failed" status' -TestCases $Cases {
                    param ($Name)
                    $DetectFail.Phases.Where{$_.Name -eq 'DetectionRules'}.Status | Should -Not -BeLike "*$ErrorMessage*"
                }
            } # Context app exists

            Context 'NewApp' {

                $ErrorMessage = 'Some error!'
                Mock Get-InstallerProperties {$Properties}
                Mock Copy-ApplicationFiles
                Mock Connect-SCCM
                Mock Get-CMApplication {throw $ErrorMessage} -ParameterFilter {$Name -like 'NewAppFail*'}

                $NewAppFail = Application 'NewAppFail' {
                    URL = $Address
                    Destination = $Dest
                    InstallWelcomeParams = '-CloseApps "code=Visual Studio Code" -CloseAppsCountdown 120 -PersistPrompt -MinimizeWindows $false'
                    UninstallWelcomeParams = '-CloseApps "code=Visual Studio Code" -CloseAppsCountdown 120 -PersistPrompt -MinimizeWindows $false'
                    Install = {Execute-MSI -Action Install -Path $PSScriptRoot\Files\%%INSTALLERNAME%%}
                    Uninstall = {Execute-MSI -Action Uninstall -Path '%%PRODUCTCODE%%'}
                    SupersedeLastVersion = {
                        Enabled = $true
                        Uninstall = $true
                    }
                    Deployments = {
                        Deploy {
                            CollectionName = '%%APPNAME%%'
                            DeployPurpose = 'Required'
                            OverrideServiceWindow = $true
                            RebootOutsideServiceWindow = $false
                        }
                    }
                    DetectionRules = {
                        RegistryValue {
                            Hive = 'LocalMachine'
                            KeyName = "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\%%ProductCode%%"
                            ValueName = 'ProductVersion'
                            PropertyType = 'Version'
                            ExpressionOperator = 'GreaterEquals'
                            ExpectedValue = '%%VERSION%%'
                        }
                        File {
                            FileName = 'Pester.exe'
                            Path = '%PROGRAMFILES%\Pester'
                        }
                    }
                }

                It 'Sets NewApp phase to Failed on error' {
                    $NewAppFail.Phases.Where{$_.Name -eq 'NewApp'}.Status | Should -BeLike 'Failed*'
                }

                It 'Includes error message with "Failed" status' {
                    $NewAppFail.Phases.Where{$_.Name -eq 'NewApp'}.Status | Should -BeLike "*$ErrorMessage*"
                }
            } # Context app exists

            Context 'DeploymentType' {

                $ErrorMessage = 'Some error!'
                Mock Get-InstallerProperties {$Properties}
                Mock Copy-ApplicationFiles
                Mock Connect-SCCM
                Mock Add-CMScriptDeploymentType {throw $ErrorMessage} -ParameterFilter {$DeploymentTypeName -like 'DeployTypeFail*'}

                $DTFail = Application DeployTypeFail {
                    URL = $Address
                    Destination = $Dest
                    InstallWelcomeParams = '-CloseApps "code=Visual Studio Code" -CloseAppsCountdown 120 -PersistPrompt -MinimizeWindows $false'
                    UninstallWelcomeParams = '-CloseApps "code=Visual Studio Code" -CloseAppsCountdown 120 -PersistPrompt -MinimizeWindows $false'
                    Install = {Execute-MSI -Action Install -Path $PSScriptRoot\Files\%%INSTALLERNAME%%}
                    Uninstall = {Execute-MSI -Action Uninstall -Path '%%PRODUCTCODE%%'}
                    SupersedeLastVersion = {
                        Enabled = $true
                        Uninstall = $true
                    }
                    Deployments = {
                        Deploy {
                            CollectionName = '%%APPNAME%%'
                            DeployPurpose = 'Required'
                            OverrideServiceWindow = $true
                            RebootOutsideServiceWindow = $false
                        }
                    }
                    DetectionRules = {
                        RegistryValue {
                            Hive = 'LocalMachine'
                            KeyName = "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\%%ProductCode%%"
                            ValueName = 'ProductVersion'
                            PropertyType = 'Version'
                            ExpressionOperator = 'GreaterEquals'
                            ExpectedValue = '%%VERSION%%'
                        }
                        File {
                            FileName = 'Pester.exe'
                            Path = '%PROGRAMFILES%\Pester'
                        }
                    }
                }

                It 'Sets DeploymentType phase to Failed on error' {
                    $DTFail.Phases.Where{$_.Name -eq 'DeploymentType'}.Status | Should -BeLike 'Failed*'
                }

                It 'Includes error message with "Failed" status' {
                    param ($Name)
                    $DTFail.Phases.Where{$_.Name -eq 'DeploymentType'}.Status | Should -BeLike "*$ErrorMessage*"
                }
            } # Context app exists

            Context 'Supersedence' {

                $ErrorMessage = 'Some error!'
                Mock Get-InstallerProperties {$Properties}
                Mock Copy-ApplicationFiles
                Mock Connect-SCCM
                Mock Get-CMApplication {throw $ErrorMessage} -ParameterFilter {$Name -eq 'SupersedeFail*'}

                $SupersedeFail = Application SupersedeFail {
                    URL = $Address
                    Destination = $Dest
                    InstallWelcomeParams = '-CloseApps "code=Visual Studio Code" -CloseAppsCountdown 120 -PersistPrompt -MinimizeWindows $false'
                    UninstallWelcomeParams = '-CloseApps "code=Visual Studio Code" -CloseAppsCountdown 120 -PersistPrompt -MinimizeWindows $false'
                    Install = {Execute-MSI -Action Install -Path $PSScriptRoot\Files\%%INSTALLERNAME%%}
                    Uninstall = {Execute-MSI -Action Uninstall -Path '%%PRODUCTCODE%%'}
                    SupersedeLastVersion = {
                        Enabled = $true
                        Uninstall = $true
                    }
                    Deployments = {
                        Deploy {
                            CollectionName = '%%APPNAME%%'
                            DeployPurpose = 'Required'
                            OverrideServiceWindow = $true
                            RebootOutsideServiceWindow = $false
                        }
                    }
                    DetectionRules = {
                        RegistryValue {
                            Hive = 'LocalMachine'
                            KeyName = "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\%%ProductCode%%"
                            ValueName = 'ProductVersion'
                            PropertyType = 'Version'
                            ExpressionOperator = 'GreaterEquals'
                            ExpectedValue = '%%VERSION%%'
                        }
                        File {
                            FileName = 'Pester.exe'
                            Path = '%PROGRAMFILES%\Pester'
                        }
                    }
                }

                It 'Sets Supersedence phase to Failed on error' {
                    $SupersedeFail.Phases.Where{$_.Name -eq 'Supersedence'}.Status | Should -BeLike 'Failed*'
                }

                It 'Includes error message with "Failed" status' {
                    param ($Name)
                    $SupersedeFail.Phases.Where{$_.Name -eq 'Supersedence'}.Status | Should -BeLike "*$ErrorMessage*"
                }
            } # Context app exists

            Context 'Dependencies' {
                
                $ErrorMessage = 'Some error!'
                $MockApps = @(
                    [PSCustomObject]@{
                        LocalizedDisplayName = 'Depend Latest'
                        IsSuperseded = $false
                        SoftwareVersion = '10.3.8'
                    }
                    [PSCustomObject]@{
                        LocalizedDisplayName = 'Depend'
                        IsSuperseded = $false
                        SoftwareVersion = '2.3.7'
                    }
                )

                Mock Get-InstallerProperties {$Properties}
                Mock Copy-ApplicationFiles
                Mock Connect-SCCM
                Mock New-CMDeploymentTypeDependencyGroup
                Mock New-CMDeploymentTypeDependencyGroup {throw $ErrorMessage} -ParameterFilter {$GroupName -eq 'Fail'}
                Mock Get-CMApplication {$MockApps} -ParameterFilter {$Name -eq "Dependency*"}
                Mock Add-CMDeploymentTypeDependency

                $SingleDepend = Application Depend {
                    URL = $Address
                    Destination = $Dest
                    InstallWelcomeParams = '-CloseApps "code=Visual Studio Code" -CloseAppsCountdown 120 -PersistPrompt -MinimizeWindows $false'
                    UninstallWelcomeParams = '-CloseApps "code=Visual Studio Code" -CloseAppsCountdown 120 -PersistPrompt -MinimizeWindows $false'
                    Install = {Execute-MSI -Action Install -Path $PSScriptRoot\Files\%%INSTALLERNAME%%}
                    Uninstall = {Execute-MSI -Action Uninstall -Path '%%PRODUCTCODE%%'}
                    SupersedeLastVersion = {
                        Enabled = $true
                        Uninstall = $true
                    }
                    Dependencies = 'Dependency'
                    Deployments = {
                        Deploy {
                            CollectionName = '%%APPNAME%%'
                            DeployPurpose = 'Required'
                            OverrideServiceWindow = $true
                            RebootOutsideServiceWindow = $false
                        }
                    }
                    DetectionRules = {
                        RegistryValue {
                            Hive = 'LocalMachine'
                            KeyName = "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\%%ProductCode%%"
                            ValueName = 'ProductVersion'
                            PropertyType = 'Version'
                            ExpressionOperator = 'GreaterEquals'
                            ExpectedValue = '%%VERSION%%'
                        }
                        File {
                            FileName = 'Pester.exe'
                            Path = '%PROGRAMFILES%\Pester'
                        }
                    }
                }
                
                $DependFail = Application DependFail {
                    URL = $Address
                    Destination = $Dest
                    InstallWelcomeParams = '-CloseApps "code=Visual Studio Code" -CloseAppsCountdown 120 -PersistPrompt -MinimizeWindows $false'
                    UninstallWelcomeParams = '-CloseApps "code=Visual Studio Code" -CloseAppsCountdown 120 -PersistPrompt -MinimizeWindows $false'
                    Install = {Execute-MSI -Action Install -Path $PSScriptRoot\Files\%%INSTALLERNAME%%}
                    Uninstall = {Execute-MSI -Action Uninstall -Path '%%PRODUCTCODE%%'}
                    SupersedeLastVersion = {
                        Enabled = $true
                        Uninstall = $true
                    }
                    Dependencies = 'Fail'
                    Deployments = {
                        Deploy {
                            CollectionName = '%%APPNAME%%'
                            DeployPurpose = 'Required'
                            OverrideServiceWindow = $true
                            RebootOutsideServiceWindow = $false
                        }
                    }
                    DetectionRules = {
                        RegistryValue {
                            Hive = 'LocalMachine'
                            KeyName = "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\%%ProductCode%%"
                            ValueName = 'ProductVersion'
                            PropertyType = 'Version'
                            ExpressionOperator = 'GreaterEquals'
                            ExpectedValue = '%%VERSION%%'
                        }
                        File {
                            FileName = 'Pester.exe'
                            Path = '%PROGRAMFILES%\Pester'
                        }
                    }
                }

                It 'Gets deployment type for latest version of dependency' {
                    Assert-MockCalled -CommandName Get-CMDeploymentType -ParameterFilter {$ApplicationName -match 'Depend Latest'} -Times 1 -Exactly -Scope Context
                }

                It 'Adds multiple dependencies if specified' {
                    $null = Application Depend {
                        URL = $Address
                        Destination = $Dest
                        InstallWelcomeParams = '-CloseApps "code=Visual Studio Code" -CloseAppsCountdown 120 -PersistPrompt -MinimizeWindows $false'
                        UninstallWelcomeParams = '-CloseApps "code=Visual Studio Code" -CloseAppsCountdown 120 -PersistPrompt -MinimizeWindows $false'
                        Install = {Execute-MSI -Action Install -Path $PSScriptRoot\Files\%%INSTALLERNAME%%}
                        Uninstall = {Execute-MSI -Action Uninstall -Path '%%PRODUCTCODE%%'}
                        SupersedeLastVersion = {
                            Enabled = $true
                            Uninstall = $true
                        }
                        Dependencies = 'Dependency1', 'Dependency2', 'Dependency3'
                        Deployments = {
                        Deploy {
                            CollectionName = '%%APPNAME%%'
                            DeployPurpose = 'Required'
                            OverrideServiceWindow = $true
                            RebootOutsideServiceWindow = $false
                        }
                    }
                        DetectionRules = {
                            RegistryValue {
                                Hive = 'LocalMachine'
                                KeyName = "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\%%ProductCode%%"
                                ValueName = 'ProductVersion'
                                PropertyType = 'Version'
                                ExpressionOperator = 'GreaterEquals'
                                ExpectedValue = '%%VERSION%%'
                            }
                            File {
                                FileName = 'Pester.exe'
                                Path = '%PROGRAMFILES%\Pester'
                            }
                        }
                    }

                    Assert-MockCalled -CommandName New-CMDeploymentTypeDependencyGroup -Times 3 -Exactly -Scope It
                    $NoDepend.Phases.Where{$_.Status -eq 'Failed'}.Count | Should -Be 0
                }

                It 'Skips dependencies section if none are specified' {
                    $NoDepend = Application Depend {
                        URL = $Address
                        Destination = $Dest
                        InstallWelcomeParams = '-CloseApps "code=Visual Studio Code" -CloseAppsCountdown 120 -PersistPrompt -MinimizeWindows $false'
                        UninstallWelcomeParams = '-CloseApps "code=Visual Studio Code" -CloseAppsCountdown 120 -PersistPrompt -MinimizeWindows $false'
                        Install = {Execute-MSI -Action Install -Path $PSScriptRoot\Files\%%INSTALLERNAME%%}
                        Uninstall = {Execute-MSI -Action Uninstall -Path '%%PRODUCTCODE%%'}
                        SupersedeLastVersion = {
                            Enabled = $true
                            Uninstall = $true
                        }
                        Deployments = {
                        Deploy {
                            CollectionName = '%%APPNAME%%'
                            DeployPurpose = 'Required'
                            OverrideServiceWindow = $true
                            RebootOutsideServiceWindow = $false
                        }
                    }
                        DetectionRules = {
                            RegistryValue {
                                Hive = 'LocalMachine'
                                KeyName = "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\%%ProductCode%%"
                                ValueName = 'ProductVersion'
                                PropertyType = 'Version'
                                ExpressionOperator = 'GreaterEquals'
                                ExpectedValue = '%%VERSION%%'
                            }
                            File {
                                FileName = 'Pester.exe'
                                Path = '%PROGRAMFILES%\Pester'
                            }
                        }
                    }

                    $NoDepend.Phases.Where{$_.Name -eq 'Dependencies'}.Status | Should -Be 'Not run'
                    $NoDepend.Phases.Where{$_.Status -eq 'Failed'}.Count | Should -Be 0

                }

                It 'Sets Dependencies phase to Success if no errors happen' {
                    $SingleDepend.Phases.Where{$_.Name -eq 'Dependencies'}.Status | Should -Be 'Success'
                }

                It 'Sets Dependencies phase to Failed on error' {
                    $DependFail.Phases.Where{$_.Name -eq 'Dependencies'}.Status | Should -BeLike 'Failed*'
                }

                It 'Includes error message with "Failed" status' {
                    param ($Name)
                    $DependFail.Phases.Where{$_.Name -eq 'Dependencies'}.Status | Should -BeLike "*$ErrorMessage*"
                }

            }

            Context 'Distribute' {

                $ErrorMessage = 'Some error!'
                $LDN = 'DistributeFail'
                $MockApps = @(
                    [PSCustomObject]@{
                        LocalizedDisplayName = $LDN
                        IsSuperseded = $false
                        SoftwareVersion = '1.3.8'
                    }
                    [PSCustomObject]@{
                        LocalizedDisplayName = $LDN
                        IsSuperseded = $false
                        SoftwareVersion = '1.3.7'
                    }
                )
                Mock Get-InstallerProperties {$Properties}
                Mock Copy-ApplicationFiles
                Mock Connect-SCCM
                Mock Get-CMApplication {$MockApps} -ParameterFilter {$Name -like "$LDN*"}
                Mock Start-CMContentDistribution {throw $ErrorMessage} -ParameterFilter {$InputObject.LocalizedDisplayName -eq $LDN}

                $DistributeFail = Application $LDN {
                    URL = $Address
                    Destination = $Dest
                    InstallWelcomeParams = '-CloseApps "code=Visual Studio Code" -CloseAppsCountdown 120 -PersistPrompt -MinimizeWindows $false'
                    UninstallWelcomeParams = '-CloseApps "code=Visual Studio Code" -CloseAppsCountdown 120 -PersistPrompt -MinimizeWindows $false'
                    Install = {Execute-MSI -Action Install -Path $PSScriptRoot\Files\%%INSTALLERNAME%%}
                    Uninstall = {Execute-MSI -Action Uninstall -Path '%%PRODUCTCODE%%'}
                    Deployments = {
                        Deploy {
                            CollectionName = '%%APPNAME%%'
                            DeployPurpose = 'Required'
                            OverrideServiceWindow = $true
                            RebootOutsideServiceWindow = $false
                        }
                    }
                    DetectionRules = {
                        RegistryValue {
                            Hive = 'LocalMachine'
                            KeyName = "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\%%ProductCode%%"
                            ValueName = 'ProductVersion'
                            PropertyType = 'Version'
                            ExpressionOperator = 'GreaterEquals'
                            ExpectedValue = '%%VERSION%%'
                        }
                        File {
                            FileName = 'Pester.exe'
                            Path = '%PROGRAMFILES%\Pester'
                        }
                    }
                }

                It 'Sets Distribute phase to Failed on error' {
                    $DistributeFail.Phases.Where{$_.Name -eq 'Distribute'}.Status | Should -BeLike 'Failed*'
                }

                It 'Includes error message with "Failed" status' {
                    param ($Name)
                    $DistributeFail.Phases.Where{$_.Name -eq 'Distribute'}.Status | Should -BeLike "*$ErrorMessage*"
                }
            } # Context app exists

            Context 'Deploy' {

                $ErrorMessage = 'Some error!'
                Mock Get-InstallerProperties {$Properties}
                Mock Copy-ApplicationFiles
                Mock Connect-SCCM
                Mock Get-CMApplicationDeployment {throw $ErrorMessage} -ParameterFilter {$Name -like 'DeployFail*'}

                $DeployFail = Application 'DeployFail' {
                    URL = $Address
                    Destination = $Dest
                    InstallWelcomeParams = '-CloseApps "code=Visual Studio Code" -CloseAppsCountdown 120 -PersistPrompt -MinimizeWindows $false'
                    UninstallWelcomeParams = '-CloseApps "code=Visual Studio Code" -CloseAppsCountdown 120 -PersistPrompt -MinimizeWindows $false'
                    Install = {Execute-MSI -Action Install -Path $PSScriptRoot\Files\%%INSTALLERNAME%%}
                    Uninstall = {Execute-MSI -Action Uninstall -Path '%%PRODUCTCODE%%'}
                    Deployments = {
                        Deploy {
                            CollectionName = '%%APPNAME%%'
                            DeployPurpose = 'Required'
                            OverrideServiceWindow = $true
                            RebootOutsideServiceWindow = $false
                        }
                    }
                    DetectionRules = {
                        RegistryValue {
                            Hive = 'LocalMachine'
                            KeyName = "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\%%ProductCode%%"
                            ValueName = 'ProductVersion'
                            PropertyType = 'Version'
                            ExpressionOperator = 'GreaterEquals'
                            ExpectedValue = '%%VERSION%%'
                        }
                        File {
                            FileName = 'Pester.exe'
                            Path = '%PROGRAMFILES%\Pester'
                        }
                    }
                }

                It 'Sets Deploy phase to Failed on error' {
                    $DeployFail.Phases.Where{$_.Name -eq 'Deploy'}.Status | Should -BeLike 'Failed*'
                }

                It 'Includes error message with "Failed" status' {
                    param ($Name)
                    $DeployFail.Phases.Where{$_.Name -eq 'Deploy'}.Status | Should -BeLike "*$ErrorMessage*"
                }

                It 'Deploys application if Deploy == $true' {
                    Mock New-CMApplicationDeployment -ParameterFilter {$Name -eq 'Pester'}
                    $DeployTrue = Application Pester {
                        URL = $Address
                        Destination = $Dest
                        InstallWelcomeParams = '-CloseApps "code=Visual Studio Code" -CloseAppsCountdown 120 -PersistPrompt -MinimizeWindows $false'
                        UninstallWelcomeParams = '-CloseApps "code=Visual Studio Code" -CloseAppsCountdown 120 -PersistPrompt -MinimizeWindows $false'
                        Install = {Execute-MSI -Action Install -Path $PSScriptRoot\Files\%%INSTALLERNAME%%}
                        Uninstall = {Execute-MSI -Action Uninstall -Path '%%PRODUCTCODE%%'}
                        Deployments = {
                        Deploy {
                            CollectionName = '%%APPNAME%%'
                            DeployPurpose = 'Required'
                            OverrideServiceWindow = $true
                            RebootOutsideServiceWindow = $false
                        }
                    }
                        DetectionRules = {
                            RegistryValue {
                                Hive = 'LocalMachine'
                                KeyName = "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\%%ProductCode%%"
                                ValueName = 'ProductVersion'
                                PropertyType = 'Version'
                                ExpressionOperator = 'GreaterEquals'
                                ExpectedValue = '%%VERSION%%'
                            }
                            File {
                                FileName = 'Pester.exe'
                                Path = '%PROGRAMFILES%\Pester'
                            }
                        }
                    }
                    $DeployTrue.Phases.Where{$_.Name -eq 'Deploy'}.Status | Should -BeLike 'Success*'
                    Assert-MockCalled -CommandName New-CMApplicationDeployment -Times 1 -Scope It
                }
    
                It 'Does not deploy application if Deploy != $true' {
                    Mock New-CMApplicationDeployment -ParameterFilter {$Name -eq 'Pester'}
                    $DeployFalse = Application Pester {
                        URL = $Address
                        Destination = $Dest
                        InstallWelcomeParams = '-CloseApps "code=Visual Studio Code" -CloseAppsCountdown 120 -PersistPrompt -MinimizeWindows $false'
                        UninstallWelcomeParams = '-CloseApps "code=Visual Studio Code" -CloseAppsCountdown 120 -PersistPrompt -MinimizeWindows $false'
                        Install = {Execute-MSI -Action Install -Path $PSScriptRoot\Files\%%INSTALLERNAME%%}
                        Uninstall = {Execute-MSI -Action Uninstall -Path '%%PRODUCTCODE%%'}
                        DetectionRules = {
                            RegistryValue {
                                Hive = 'LocalMachine'
                                KeyName = "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\%%ProductCode%%"
                                ValueName = 'ProductVersion'
                                PropertyType = 'Version'
                                ExpressionOperator = 'GreaterEquals'
                                ExpectedValue = '%%VERSION%%'
                            }
                            File {
                                FileName = 'Pester.exe'
                                Path = '%PROGRAMFILES%\Pester'
                            }
                        }
                    }
                    $DeployFalse.Phases.Where{$_.Name -eq 'Deploy'}.Status | Should -Be 'Not run'
                    Assert-MockCalled -CommandName New-CMApplicationDeployment -Times 0 -Scope It
                }
            } # Context app exists

        }
    }
}