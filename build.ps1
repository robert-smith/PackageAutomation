[cmdletbinding()]
param(
    [string[]]$Task = 'test'
)

# ASCII colors for pretty output
$Esc = "$([char]27)"
$Green = "$Esc[32;1m"
$Yellow = "$Esc[33;1m"
$Reset = "$Esc[0m"

# Install pre-reqs
Write-Host -Object 'Installing pre-reqs...'

$Modules = @(
    @{
        Name = 'Pester'
        RequiredVersion = '4.9.0'
    }
    @{
        Name = 'psake'
    }
    @{
        Name = 'PlatyPS'
    }
    @{
        Name = 'AzureAD'
    }
    @{
        Name = 'PSIntuneAuth'
    }
)

# Set TLS version to 1.2. Otherwise, downloads to the PowerShell gallery will be denied.
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$ErrorActionPreference = 'Stop'

Write-Host -Object '  Modules:'
foreach ($Module in $Modules) {
    Write-Host -Object ('  - ' + $Module.Name + '...') -NoNewline
    $Available = Find-Module @Module
    $Installed = (Get-Module -Name $Module.Name -ListAvailable).Where{$_.Version -eq $Available.Version}
    if (-not $Installed) {
        Install-Module @Module -Force
        Write-Host -Object ($Green + 'Installed: ' + $Reset + $Available.Version)
    }
    else {
        Write-Host -Object ($Yellow + 'Skipped: ' + $Reset + 'Already installed.')
    }
    # Force the module to be reimported
    Remove-Module -Name $Module.Name -Force -ErrorAction SilentlyContinue
    Import-Module @Module -Force
}

$Module = Resolve-Path -Path $PSScriptRoot\src\*.psd1
Import-Module $Module.Path -Force
Invoke-psake -buildFile "$PSScriptRoot\psakeBuild.ps1" -taskList $Task -Verbose:$VerbosePreference

exit ( [int]( -not $psake.build_success ) )
