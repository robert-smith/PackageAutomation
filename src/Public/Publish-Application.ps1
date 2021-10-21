function Publish-Application {
    [CmdletBinding()]
    [Alias('Application')]
    param (
        [Parameter(Mandatory)]
        [string]$Name,
        [Parameter(Mandatory)]
        [scriptblock]$ScriptBlock
    )

    begin {
        # Get script invocation path
        $Script:PackageConfigPath = $Local:MyInvocation.PSScriptRoot

        # Output title of application
        Write-Host -Object ($ANSI.Yellow + $Name + $ANSI.Reset)

        # Create temp directory
        $Script:PATempDir = "$env:TEMP\PackageAutomation\$Name"
        New-Item -Path $PATempDir -ItemType Directory -Force > $null

        $Script:Results = Initialize-Phases -AppName $Name
    }

    process {
        # Define variable for keeping track of the phase. This is so that Write-Fail can
        # set the appropriate phase property on the output object.
        Start-Phase -Phase Initialize
        $Splat = Convert-ScriptblockToHashtable -ScriptBlock $ScriptBlock
        try {
            Invoke-PackageCreation -Name $Name @Splat -ErrorAction Stop
        }
        catch {
            Write-Fail
        }
    }

    end {
        # Go back to the old console location
        Pop-Location
        # Clean up any temp file
        Remove-Item -Path $PATempDir -Recurse -Force

        return $Results
    }
}