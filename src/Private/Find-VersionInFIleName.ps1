function Find-VersionInFileName {
    param (
        [string]$File
    )

    # Grab just the file name if a path was given instead
    $FileName = [io.path]::GetFileName($File)

    $Regex = '((\d+\.)+\d+)'
    $Version = [regex]::Match($FileName, $Regex).Groups[0].Value
    return $Version
}