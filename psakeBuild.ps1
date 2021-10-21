task default -depends Test

task Help {
    New-ExternalHelp -Path $PSScriptRoot\docs\Cmdlets -OutputPath $PSScriptRoot\src\en-us -Force
}

task Test {
    $scripts = Get-ChildItem -Path $PSScriptRoot\Src\Private\*.ps1, $PSScriptRoot\Src\Public\*.ps1 -ErrorAction SilentlyContinue
    $results = Invoke-Pester -Script $PSScriptRoot\tests -CodeCoverage $scripts.FullName -PassThru
    $coverage = [int]($results.CodeCoverage.NumberOfCommandsExecuted /
                      $results.CodeCoverage.NumberOfCommandsAnalyzed * 100)
    $coverage = [math]::Round(($coverage),1)
    Write-Output "Total code coverage: $coverage%"
    if ($results.FailedCount -gt 0) {
        $format = @(
            @{
                label = 'Command'
                expression = {$_.Describe}
            }

            @{
                label = 'Test Name'
                expression = {$_.Name}
            }

            @{
                label = 'Reason'
                expression = {$_.FailureMessage}
            }
        )
        Write-Output '[31;1m[FAILED TESTS]' # [31;1m Starts red highlighting in Gitlab
        $results.TestResult | Where-Object {$_.Result -eq 'Failed'} | Format-List -Property $format
        Write-Output '[0;m' # [0;m returns Gitlab hightlighting to white
        Write-Error -Message 'One or more Pester tests failed. Build cannot continue!'
    }
}
