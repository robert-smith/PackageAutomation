function Get-MsiProperty {
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $True, ValueFromPipeline = $true)]
        [IO.FileInfo[]]$Path,
        [AllowEmptyString()]
        [AllowNull()]
        [string[]]$Property
    )
    Begin {
        try {
            $Resolved = Resolve-Path -Path $Path -ErrorAction Stop
            # Strip away PowerShell UNC path prefix if present
            $Resolved = Convert-Path -Path $Resolved.Path
        }
        catch {
            throw 'Invalid path.'
            return
        }
        $WindowsInstaller = New-Object -ComObject WindowsInstaller.Installer
    }
    Process {
        try {
            $MSIDatabase = $WindowsInstaller.GetType().InvokeMember('OpenDatabase', 'InvokeMethod', $null, $WindowsInstaller, @("$Resolved", 0))
            if ($Property) {
                $PropertyQuery = 'WHERE ' + (($Property | ForEach-Object { "Property = '$($_)'" }) -join ' OR ')
            }
            $Query = ("SELECT Property,Value FROM Property {0}" -f ($PropertyQuery))
 
            $View = $MSIDatabase.GetType().InvokeMember('OpenView', 'InvokeMethod', $null, $MSIDatabase, ($Query))
            $null = $View.GetType().InvokeMember('Execute', 'InvokeMethod', $null, $View, $null)
 
            $MSIInfo = [PSCustomObject]@{'File' = $Resolved }
            do {
                $null = $View.GetType().InvokeMember('ColumnInfo', 'GetProperty', $null, $View, 0)
                $Record = $View.GetType().InvokeMember('Fetch', 'InvokeMethod', $null, $View, $null)
                if (-not $Record) { break; }
                $PropertyName = $Record.GetType().InvokeMember('StringData', 'GetProperty', $null, $Record, 1) | Select-Object -First 1
                $Value = $Record.GetType().InvokeMember('StringData', 'GetProperty', $null, $Record, 2) | Select-Object -First 1
                Add-Member -MemberType NoteProperty -Name $PropertyName -Value $Value -InputObject $MSIInfo
            } while ($true)
 
            $null = $MSIDatabase.GetType().InvokeMember('Commit', 'InvokeMethod', $null, $MSIDatabase, $null)
            $null = $View.GetType().InvokeMember('Close', 'InvokeMethod', $null, $View, $null)           
        }
        catch {
            Write-Warning -Message $_
            Write-Warning -Message $_.ScriptStackTrace
 
        }
    }
    End {
        try {
            $null = [Runtime.Interopservices.Marshal]::ReleaseComObject($WindowsInstaller)
            Remove-Variable -Name WindowsInstaller, MSIDatabase, View -Force
            [GC]::Collect()
        }
        catch {
            Write-Warning -Message 'Failed to release Windows Installer COM reference'
            Write-Warning -Message $_
        }

        # Pause before outputting to give time for the file lock to clear.
        Start-Sleep -Milliseconds 100
        return $MSIInfo
    }
}