$parent = Split-Path -Path $PSScriptRoot -Parent
$module = Split-Path -Path $parent -Leaf
Remove-Module $module -Force -ErrorAction SilentlyContinue
Import-Module $parent\Src\$module.psd1 -Force

Describe "$module - Wait-FileLock" {
    InModuleScope PackageAutomation {
        $File = "$env:TEMP\test.txt"
        
        It 'Does not throw if file is not locked' {
            # Create dummy file
            'Test' > $File
            {Wait-FileLock -Path $File -Timeout 1} | Should -Not -Throw
            Remove-Item -Path $File -Force
        }

        It 'Throws if file is locked for longer than the timeout' {
            # Create a background job to temporarily lock the file
            Start-Job -Name 'Lock file' -ArgumentList $File -ScriptBlock {
                param ($File)
                'Test' > $File
                $FileStream = [System.IO.File]::Open("$File",'Open','Write')
                Start-Sleep -Seconds 5
                $FileStream.Close()
                $FileStream.Dispose()
            }
            # Wait for job to start before checking file lock
            do {
                $Exists = Test-Path -Path $File
                Start-Sleep -Seconds 1
            }
            until ($Exists)
            {Wait-FileLock -Path $File -Timeout 1} | Should -Throw
            # Cleanup
            Get-Job | Wait-Job | Remove-Job -Force
        }
        
        Remove-Item -Path $File -Force
    }
}