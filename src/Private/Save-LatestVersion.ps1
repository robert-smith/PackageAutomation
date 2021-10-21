<#

.SYNOPSIS
The purpose of this function is to compare the latest version available with what is already
in the destination subdirectories. If the destination does not include the new version, it
will download it. An item object will be returned for either the existing installer or the
newly downlaoded one.

#>

function Save-LatestVersion {
    [CmdletBinding()]
    param (
        [string]$URL,
        [string]$Destination,
        [scriptblock]$Metadata
    )

    Start-Phase -Phase GetURL
    $Download = Get-RedirectURL -URL $URL
    Complete-Phase -Status Done

    Start-Phase -Phase CheckVersion
    $File = Split-Path -Path $Download -Leaf
    # Convert any escaped characters such as %20 into actual characters
    $File = [uri]::UnescapeDataString($File)
    $Extension = [IO.Path]::GetExtension($File)
    # Append version to file name if overridden in Metadata
    $OverrideHash = Convert-ScriptblockToHashtable -Scriptblock $Metadata
    if ($OverrideHash.Version) {
        $Version = $OverrideHash.Version
        $FileName = [io.path]::GetFileNameWithoutExtension($File)
        $File = $FileName + "-$Version" + $Extension
    }

    $Existing = Get-ChildItem -Path $Destination -Recurse -Filter $File -File
    if ($Existing) {
        Complete-Phase -Status OK
        return $Existing
        
    }
    else {
        Complete-Phase -Status Done -Details 'New version available'   
        $DownloadDest = "$Destination\$File"
        $New = Start-FileDownload -URL $Download -Destination $DownloadDest
        return $New
    }
}
