$parent = Split-Path -Path $PSScriptRoot
$module = Split-Path -Path $parent -Leaf
Remove-Module $module -Force -ErrorAction SilentlyContinue
Import-Module $parent\Src\$module.psd1 -Force

Describe "$module - Help" {
    $cmds = Get-Command -Module $module
    foreach ($cmd in $cmds) {
        Context $cmd.Name {
            $help = Get-Help $cmd.Name -Full
            It 'Has a description' {
                $help.description | Should Not BeNullOrEmpty
            }
            It 'Has examples' {
                ($help.examples.example | Measure-Object).Count | Should Not BeExactly 0
            }
        }
    }
}