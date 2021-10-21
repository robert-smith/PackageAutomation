function Wait-FileLock {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Path,
        [int]$Timeout = 5
    )

    $i = $Timeout * 10
    while ($i -gt 0) {
        try {
            $FileStream = [System.IO.File]::Open("$Path",'Open','Write')
            $FileStream.Close()
            $FileStream.Dispose()
            return
        }
        catch {
            $i--
            Start-Sleep -Milliseconds 100
        }
    }

    # If timeout reached
    throw "$Path was still locked after waiting $Timeout seconds."
}