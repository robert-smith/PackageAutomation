$parent = Split-Path -Path $PSScriptRoot -Parent
$module = Split-Path -Path $parent -Leaf
Remove-Module $module -Force -ErrorAction SilentlyContinue
Import-Module $parent\Src\$module.psd1 -Force

Describe "$module - General" {
    Context Module {
        $cmds = Get-Command -Module $module
        $scripts = Get-ChildItem -Path $parent\Src\Public\*.ps1 -ErrorAction SilentlyContinue
        
        It 'Loads all scripts in Public' {
            $cmds.Count | Should Be $scripts.Count
        }
    }
}