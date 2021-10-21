function Invoke-Executable {
    param(
        [parameter(Mandatory = $true, HelpMessage = "Specify the file name or path of the executable to be invoked, including the extension.")]
        [ValidateNotNullOrEmpty()]
        [string]$FilePath,

        [parameter(Mandatory = $false, HelpMessage = "Specify arguments that will be passed to the executable.")]
        [ValidateNotNull()]
        [string]$Arguments,
        [bool]$Quiet
    )

    # Construct a hash-table for default parameter splatting
    $SplatArgs = @{
        FilePath = $FilePath
        NoNewWindow = $true
        Passthru = $true
        ErrorAction = "Stop"
        Wait = $True
    }

    # Add ArgumentList param if present
    if (-not([System.String]::IsNullOrEmpty($Arguments))) {
        $SplatArgs.Add("ArgumentList", $Arguments)
    }

    # Redirect stdout if Quiet is set
    $NullFile = "$env:TEMP\null.txt"
    if ($Quiet) {
        $SplatArgs.RedirectStandardOutput = $NullFile
    }
    # Invoke executable and wait for process to exit
    try {
        $Invocation = Start-Process @SplatArgs
        Remove-Item -Path $NullFile -Force -ErrorAction SilentlyContinue
    }
    catch [System.Exception] {
        Write-Warning -Message $_.Exception.Message; break
    }

    return $Invocation.ExitCode
}