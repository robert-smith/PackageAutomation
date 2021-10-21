function Get-OrderedAppVersion {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Name
    )
    $Sorted = Get-CMApplication -Name "$Name*" | Sort-Object -Property {[version]$_.SoftwareVersion} -Descending
    return $Sorted
}