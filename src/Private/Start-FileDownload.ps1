<#

.SYNOPSIS
The purpose of this function is to download a file and output the status
and result to the screen.

#>

function Start-FileDownload {
    [CmdletBinding()]
    param (
        [string]$URL,
        [string]$Destination
    )
    Start-Phase -Phase Download

    # If URL does not end in .msi, .exe, or .zip, fail to avoid downloading a weird file.
    if ($URL -notmatch '(\.exe|\.msi|\.zip)$') {
        throw "URL is not an MSI or EXE file: $URL"
    }
    $WebClient = New-Object -TypeName System.Net.WebClient
    $WebClient.Headers.Add('User-Agent',[Microsoft.PowerShell.Commands.PSUserAgent]::Chrome)
    $WebClient.DownloadFile($URL, $Destination)
    $File = Get-Item -Path $Destination
    Complete-Phase -Status Done
    return $File
}