$parent = Split-Path -Path $PSScriptRoot -Parent
$module = Split-Path -Path $parent -Leaf
Remove-Module $module -Force -ErrorAction SilentlyContinue
Import-Module $parent\Src\$module.psd1 -Force

Describe "$module - Convert-ScriptblockToHashtable" {
    InModuleScope PackageAutomation {

        It 'Converts scriptblock into a hashtable with properties' {
            $Scriptblock = {
                Manufacturer = 'Adobe Inc.'
                Version = '1.2.3.0'
            }
            $Output = Convert-ScriptblockToHashtable -Scriptblock $Scriptblock
            $Output.Manufacturer | Should -BeExactly 'Adobe Inc.'
            $Output.Version | Should -BeExactly '1.2.3.0'
        }

    }
}