<#

.SYNOPSIS
The purpose of this function is to return the manufacturer, version, and product code (if the
file is an MSI). An MSI alawys includes that information, whereas an executable may sometimes
store that in its metadata.

#>

function Get-InstallerProperties {
    [CmdletBinding()]
    param (
        [string]$Path,
        [scriptblock]$Metadata = {}
    )

    begin {
        Start-Phase -Phase MSIProps
        $Extension = [IO.Path]::GetExtension($Path)
    }

    process {
        if ($Extension -eq '.msi') {
            $Properties = Get-MsiProperty -Path $Path
            
            # To make the output from this command consistent, create a property called Version with the same
            # value as ProductVersion since Get-FileMetadata returns a property called Version
            [version]$FormattedVersion = $Properties.ProductVersion
            Add-Member -InputObject $Properties -MemberType NoteProperty -Name Version -Value $FormattedVersion -Force
        }
        else {
            $Properties = Get-FileMetadata -Path $Path
        }
        
        # Inject Metadata
        $OverrideHash = Convert-ScriptblockToHashtable -Scriptblock $Metadata
        foreach ($key in $OverrideHash.Keys) {
            $Value = $OverrideHash.$key
            # Only inject overrides if there are values. That way we don't clear values we want to keep.
            if ($Value) {
                $Properties.$Key = $Value
            }
        }

        # If there is no version info in the metadata attempt to extract from file name
        if (-not $Properties.Version) {
            $Version = Find-VersionInFileName -File $Path
            if ($Version) {
                $Properties.Version = $Version
            }
            else {
                throw 'Unable to determine installer version.'
            }
        }
    }

    end {
        Complete-Phase -Status Done
        return $Properties
    }
}