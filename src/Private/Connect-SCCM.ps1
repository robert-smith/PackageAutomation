<#

The purpose of this command is to connect to SCCM using the SCCM PowerShell
module, create a PS drive to SCCM, then set the console's location to the
drive. Setting the location to the drive is required for the SCCM module
commands to work. Setting the location must happen later in the script
because while in the SCCM drive, attempting to access files outside of it
such as ones on network shares or local drives can fail.

#>

function Connect-SCCM {
    [CmdletBinding()]
    param (
    )

    Start-Phase -Phase ConnectSccm
    
    $CMModule = Resolve-Path "$env:ProgramFiles*\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1"
    Import-Module $CMModule.Path -Force -Scope Global

    # It appears that New-PSDrive only persists in the Local scope, aka this function block
    # Setting the scope to either Global or Script prevents the "Object reference not set to an instance of an object" error
    $Drive = 'CCM'
    $Server = (Get-CimInstance -Namespace "root\ccm" -class 'SMS_LookupMP').Name
    New-PSDrive -Name $Drive -PSProvider CMSite -Root $Server -Scope Script -ErrorAction SilentlyContinue > $null
    Set-Location -Path ($Drive + ':')
    Complete-Phase -Status Done
}