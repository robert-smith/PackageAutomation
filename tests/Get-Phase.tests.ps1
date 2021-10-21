$parent = Split-Path -Path $PSScriptRoot -Parent
$module = Split-Path -Path $parent -Leaf
Remove-Module $module -Force -ErrorAction SilentlyContinue
Import-Module $parent\Src\$module.psd1 -Force

Describe "$module - Get-Phase" {
    InModuleScope PackageAutomation {

        $Script:Results = @{
            Name = 'PesterTest'
            Phases = @(
                [PSCustomObject]@{
                    Name = 'Initialize'
                    Status = 'Not run'
                },
                [PSCustomObject]@{
                    Name = 'GetURL'
                    Status = 'Not run'
                },
                [PSCustomObject]@{
                    Name = 'CheckVersion'
                    Status = 'Not run'
                },
                [PSCustomObject]@{
                    Name = 'Download'
                    Status = 'Running'
                },
                [PSCustomObject]@{
                    Name = 'MSIProps'
                    Status = 'Not run'
                },
                [PSCustomObject]@{
                    Name = 'CopyFiles'
                    Status = 'Not run'
                },
                [PSCustomObject]@{
                    Name = 'ConnectSCCM'
                    Status = 'Not run'
                },
                [PSCustomObject]@{
                    Name = 'DetectionRules'
                    Status = 'Not run'
                },
                [PSCustomObject]@{
                    Name = 'NewApp'
                    Status = 'Not run'
                },
                [PSCustomObject]@{
                    Name = 'DeploymentType'
                    Status = 'Not run'
                },
                [PSCustomObject]@{
                    Name = 'Supersedence'
                    Status = 'Not run'
                },
                [PSCustomObject]@{
                    Name = 'Dependencies'
                    Status = 'Not run'
                },
                [PSCustomObject]@{
                    Name = 'CreateCollection'
                    Status = 'Not run'
                },
                [PSCustomObject]@{
                    Name = 'Distribute'
                    Status = 'Not run'
                },
                [PSCustomObject]@{
                    Name = 'Deploy'
                    Status = 'Not run'
                }
            )
        }

        It 'Outputs the current running phase' -TestCases $TestCases {
            $Phase = Get-Phase
            $Phase.Name | Should -BeExactly 'Download'
        }

    }
}