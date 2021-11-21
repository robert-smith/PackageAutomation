$parent = Split-Path -Path $PSScriptRoot -Parent
$module = Split-Path -Path $parent -Leaf
Remove-Module $module -Force -ErrorAction SilentlyContinue
Import-Module $parent\Src\$module.psd1 -Force
$CMDlls = Get-ChildItem -Path "$PSScriptRoot\ConfigurationManager\*.dll"
foreach ($Dll in $CMDlls) {
    [Reflection.Assembly]::LoadFile($Dll.FullName) | out-null
}
Import-Module "$PSScriptRoot\ConfigurationManager\ConfigurationManager.psd1" -Force -Scope Global -ErrorAction SilentlyContinue

Describe "$module - Convert-DetectionToIntune" {
    InModuleScope PackageAutomation {
        Context File {
            
            $KeyCases = @(
                @{Key = '@odata.type'; Value = '#microsoft.graph.win32LobAppFileSystemDetection'}
                @{Key = 'detectionValue'; Value = '1.2.3'}
                @{Key = 'path'; Value = 'C:\Temp'}
                @{Key = 'fileOrFolderName'; Value = 'test.exe'}
                @{Key = 'check32BitOn64System'; Value = $false}
            )

            It 'Properly converts <Key>' -TestCases $KeyCases {
                param ($Key, $Value)
                $SCCMDetect = file {
                    FileName = 'test.exe'
                    Path = 'C:\Temp'
                    PropertyType = 'Version'
                    ExpectedValue = '1.2.3'
                    ExpressionOperator = 'IsEquals'
                }
                $Rule = Convert-DetectionToIntune $SCCMDetect
                $Rule.$Key | Should -Be $Value
            }

            $OperatorCases = @(
                @{IntuneOp = 'equal'; SCCMOp = 'IsEquals'}
                @{IntuneOp = 'greaterThan'; SCCMOp = 'GreaterThan'}
                @{IntuneOp = 'greaterThanOrEqual'; SCCMOp = 'GreaterEquals'}
                @{IntuneOp = 'lessThan'; SCCMOp = 'LessThan'}
                @{IntuneOp = 'lessThanOrEqual'; SCCMOp = 'LessEquals'}
                @{IntuneOp = 'notEqual'; SCCMOp = 'NotEquals'}
            )
            It "Properly converts <SCCMOp> SCCM operator to <IntuneOp> Intune operator" -TestCases $OperatorCases {
                param ($IntuneOp, $SCCMOp)
                $FileString = "
                    FileName = 'test.exe'
                    Path = 'C:\Temp'
                    PropertyType = 'Version'
                    ExpectedValue = '1.2.3'
                    ExpressionOperator = '$SCCMOp'"
                $FileBlock = [scriptblock]::Create($FileString)
                $SCCMDetect = file $FileBlock
                $IntuneDetect = Convert-DetectionToIntune $SCCMDetect
                $IntuneDetect.operator | Should -Be $IntuneOp
            }
        }

        Context Registry {
            $KeyCases = @(
                @{Key = '@odata.type'; Value = '#microsoft.graph.win32LobAppRegistryDetection'}
                @{Key = 'detectionValue'; Value = '1.2.3'}
                @{Key = 'keyPath'; Value = 'HKEY_LOCAL_MACHINE\Software\Test'}
                @{Key = 'valueName'; Value = 'Version'}
                @{Key = 'check32BitOn64System'; Value = $false}
            )

            It 'Properly converts <Key>' -TestCases $KeyCases {
                param ($Key, $Value)
                $SCCMDetect = RegistryValue {
                    Hive = 'LocalMachine'
                    KeyName = 'SOFTWARE\Test'
                    ValueName = 'Version'
                    PropertyType = 'Version'
                    ExpectedValue = '1.2.3'
                    ExpressionOperator = 'IsEquals'
                }
                $Rule = Convert-DetectionToIntune $SCCMDetect
                $Rule.$Key | Should -Be $Value
            }

            $OperatorCases = @(
                @{IntuneOp = 'equal'; SCCMOp = 'IsEquals'}
                @{IntuneOp = 'greaterThan'; SCCMOp = 'GreaterThan'}
                @{IntuneOp = 'greaterThanOrEqual'; SCCMOp = 'GreaterEquals'}
                @{IntuneOp = 'lessThan'; SCCMOp = 'LessThan'}
                @{IntuneOp = 'lessThanOrEqual'; SCCMOp = 'LessEquals'}
                @{IntuneOp = 'notEqual'; SCCMOp = 'NotEquals'}
            )
            It "Properly converts <SCCMOp> SCCM operator to <IntuneOp> Intune operator" -TestCases $OperatorCases {
                param ($IntuneOp, $SCCMOp)
                $RegistryString = "
                    Hive = 'LocalMachine'
                    KeyName = 'SOFTWARE\Test'
                    ValueName = 'Version'
                    PropertyType = 'Version'
                    ExpectedValue = '1.2.3'
                    ExpressionOperator = '$SCCMOp'"
                $RegistryBlock = [scriptblock]::Create($RegistryString)
                $SCCMDetect = RegistryValue $RegistryBlock
                $IntuneDetect = Convert-DetectionToIntune $SCCMDetect
                $IntuneDetect.operator | Should -Be $IntuneOp
            }

            $DetectCases = @(
                @{DetectType = 'Integer'; Value = 1}
                @{DetectType = 'String'; Value = 'One'}
                @{DetectType = 'Version'; Value = '1.0.0'}
            )

            It "Properly converts <DetectType> detection type" -TestCases $DetectCases {
                param ($DetectType, $Value)
                $RegistryString = "
                    Hive = 'LocalMachine'
                    KeyName = 'SOFTWARE\Test'
                    ValueName = 'Version'
                    PropertyType = '$DetectType'
                    ExpectedValue = '$Value'
                    ExpressionOperator = 'IsEquals'"
                $RegistryBlock = [scriptblock]::Create($RegistryString)
                $SCCMDetect = RegistryValue $RegistryBlock
                $IntuneDetect = Convert-DetectionToIntune $SCCMDetect
                $IntuneDetect.detectionType | Should -Be $DetectType
            }
        }

        # MSI Detection has not been added yet
        #Context MSI {
        #    $KeyCases = @(
        #        @{Key = '@odata.type'; Value = '#microsoft.graph.win32LobAppProductCodeDetection'}
        #        @{Key = 'productCode'; Value = '{0d4b949c-3432-40ab-8034-447ca7037c58}'}
        #        @{Key = 'productVersion'; Value = '1.2.3'}
        #    )

        #    It 'Properly converts <Key>' -TestCases $KeyCases {
        #        param ($Key, $Value)
        #        $SCCMDetect = file {
        #            FileName = 'test.exe'
        #            Path = 'C:\Temp'
        #            PropertyType = 'Version'
        #            ExpectedValue = '1.2.3'
        #            ExpressionOperator = 'IsEquals'
        #        }
        #        $Rule = Convert-DetectionToIntune $SCCMDetect
        #        $Rule.$Key | Should -Be $Value
        #    }

        #    $OperatorCases = @(
        #        @{IntuneOp = 'equal'; SCCMOp = 'IsEquals'}
        #        @{IntuneOp = 'greaterThan'; SCCMOp = 'GreaterThan'}
        #        @{IntuneOp = 'greaterThanOrEqual'; SCCMOp = 'GreaterEquals'}
        #        @{IntuneOp = 'lessThan'; SCCMOp = 'LessThan'}
        #        @{IntuneOp = 'lessThanOrEqual'; SCCMOp = 'LessEquals'}
        #        @{IntuneOp = 'notEqual'; SCCMOp = 'NotEquals'}
        #    )
        #    It "Properly converts <SCCMOp> SCCM operator to <IntuneOp> Intune operator" -TestCases $OperatorCases {
        #        param ($IntuneOp, $SCCMOp)
        #        $FileString = "
        #            FileName = 'test.exe'
        #            Path = 'C:\Temp'
        #            PropertyType = 'Version'
        #            ExpectedValue = '1.2.3'
        #            ExpressionOperator = '$SCCMOp'"
        #        $FileBlock = [scriptblock]::Create($FileString)
        #        $SCCMDetect = file $FileBlock
        #        $IntuneDetect = Convert-DetectionToIntune $SCCMDetect
        #        $IntuneDetect.operator | Should -Be $IntuneOp
        #    }
        #}
    }
}