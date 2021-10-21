$parent = Split-Path -Path $PSScriptRoot -Parent
$module = Split-Path -Path $parent -Leaf
Remove-Module $module -Force -ErrorAction SilentlyContinue
Import-Module $parent\Src\$module.psd1 -Force

Describe "$module - Find-VersionInFileName" {
    InModuleScope PackageAutomation {
        
        $TestCases = @(
            @{FileName = 'ActivInspire_v2.16.67968_AppOnly_setup.exe'; Version = '2.16.67968'}
            @{FileName = 'Airtame-4.1.0-setup.exe'; Version = '4.1.0'}
            @{FileName = 'anyconnect-win-4.4.03034-core-vpn-webdeploy-k9.exe'; Version = '4.4.03034'}
            @{FileName = 'azuredatastudio-windows-setup-1.14.1.exe'; Version = '1.14.1'}
            @{FileName = 'blackbox_exporter-0.16.0.windows-amd64.tar.gz'; Version = '0.16.0'}
            @{FileName = 'Cricut Design Space Install v5.14.79.exe'; Version = '5.14.79'}
            @{FileName = 'Dell-Command-Update_5P2R9_WIN_3.1.3_A00.EXE'; Version = '3.1.3'}
            @{FileName = 'gam-5.10-windows-x86_64.msi'; Version = '5.10'}
            @{FileName = 'goguardian-app-1.4.3.msi'; Version = '1.4.3'}
            @{FileName = 'graylog_sidecar_installer_1.0.2-1.exe'; Version = '1.0.2'}
            @{FileName = 'Loom Setup 0.56.0.exe'; Version = '0.56.0'}
            @{FileName = 'MakeMeAdmin-2.3.zip'; Version = '2.3'}
            @{FileName = 'NaviCLI-Win-32-x86-en_US-7.33.9.2.36-1.exe'; Version = '7.33.9.2.36'}
            @{FileName = 'node-v12.16.3-x64.msi'; Version = '12.16.3'}
            @{FileName = 'OBS-Studio-23.2.1-Full-Installer-x64.exe'; Version = '23.2.1'}
            @{FileName = 'OBS-Studio-24.0.3-Full-Installer-x64.exe'; Version = '24.0.3'}
            @{FileName = 'OpenDNS-URC-win-2.2.356.zip'; Version = '2.2.356'}
            @{FileName = 'pc-mobility-print-1.0.2947.exe'; Version = '1.0.2947'}
            @{FileName = 'PowerShell-7.0.0-rc.2-win-x64.msi'; Version = '7.0.0'}
            @{FileName = 'ScreenShare_MSI_v1.8.1.2.msi'; Version = '1.8.1.2'}
            @{FileName = 'Screen_Share.1.8.1.2.exe'; Version = '1.8.1.2'}
            @{FileName = 'Screen_Share.1.9.7.1.exe'; Version = '1.9.7.1'}
            @{FileName = 'vagrant_2.2.7_x86_64.msi'; Version = '2.2.7'}
            @{FileName = 'wmi_exporter-0.9.0-amd64.msi'; Version = '0.9.0'}
        )

        It 'Finds version in <FileName>' -TestCases $TestCases {
            param ($FileName, $Version)
            Find-VersionInFileName -File $FileName | Should -BeExactly $Version
        }

    }
}