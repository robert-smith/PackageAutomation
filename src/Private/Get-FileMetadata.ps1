function Get-FileMetadata {
    [CmdletBinding()]
    param (
        [ValidateScript({
            if (-not (Test-Path -Path $_)) {
                throw "$_ does not exist."
            }
            else {
                $true
            }
        })]
        [string]$Path
    )

    begin {
        $Properties = @{
            Manufacturer = 'Company'
            FileVersion = 'FileVersion'
            ProductVersion = 'ProductVersion'
            Description = 'Description'
            Author = 'Author'
        }
        $Output = New-Object -TypeName PSCustomObject
        $Resolved = Resolve-Path -Path $Path
        $Resolved = Convert-Path -Path $Resolved.Path
        $Parent = Split-Path -Path $Resolved -Parent
        $File = Split-Path -Path $Resolved -Leaf
        $shell = new-object -com shell.application
        $folder = $shell.namespace($Parent)
        $target = $folder.Items().Item($File)
    }

    process {
        foreach ($item in $Properties.Keys) {
            $Splat = @{
                InputObject = $Output
                MemberType = 'NoteProperty'
                Name = $item
                Value = $target.ExtendedProperty($Properties.$item)
            }
            Add-Member @Splat
        }
    }

    end {
        return $Output
    }
}