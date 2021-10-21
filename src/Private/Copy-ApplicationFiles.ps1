<#

.SYNOPSIS
The purpose of this function is to create a new directory named after the version of
the installer, copy the PS ADT files to the new directory, copy the installer to the
new directory, inject the parameter values into a template Deploy-Application.ps1 file
in their correct locations, and finally copy the Deploy-Application.ps1 file to the
newly created directory.

#>

function Copy-ApplicationFiles {
    [CmdletBinding()]
    param (
        [string]$AppName,
        [string]$RootPath,
        [string]$Installer,
        [string]$Version,
        [string]$Manufacturer,
        [string]$InstallWelcomeParams,
        [string]$PreInstall,
        [string]$Install,
        [string]$PostInstall,
        [string]$UninstallWelcomeParams,
        [string]$PreUninstall,
        [string]$Uninstall,
        [string]$PostUninstall
    )

    Start-Phase -Phase CopyFiles
    # Drop down a line
    Write-Host -Object ''

    $FilesPath = "$RootPath\$Version\Files"
    $InstallerName = Split-Path -Path $Installer -Leaf
    # Create new directory named after the installer version
    New-Item -Path $FilesPath -ItemType Directory -Force > $null

    $Actions = [System.Collections.ArrayList]@()

    $InstallerExists = Test-Path -Path "$FilesPath\$InstallerName"
    if ($InstallerExists) {
        $InstallerAction = @{
            Name = 'Installer'
            Action = 'None'
        }
    }
    else {
        $InstallerAction = @{
            Name = 'Installer'
            Source = $Installer
            Destination = $FilesPath
            Action = 'Move'
        }
    }
    $Actions.Add($InstallerAction) > $null

    # Copy over extra files
    $Extras = Get-ChildItem -Path "$PackageConfigPath\Files" -ErrorAction SilentlyContinue
    foreach ($File in $Extras) {
        $Exists = Test-Path -Path "$FilesPath\$($File.Name)"
        if ($Exists) {
            $Action = @{
                Name = $File.Name
                Action = 'None'
            }
        }
        else {
            $Action = @{
                Name = $File.Name
                Source = $File.FullName
                Destination = $FilesPath
                Action = 'Copy'
            }
        }
        $Actions.Add($Action) > $null
    }
    
    $FormatArray = @(
        $AppName
        $Version
        $Manufacturer
        $InstallWelcomeParams
        $PreInstall
        $Install
        $PostInstall
        $UninstallWelcomeParams
        $PreUninstall
        $Uninstall
        $PostUninstall
    )

    # Copy PowerShell Application Deployment Toolkit files
    $ParentDir = Split-Path -Path $PSScriptRoot -Parent
    $Resources = "$ParentDir\Resources"
    $PSADTSource = Get-ChildItem -Path $Resources\PSADT -Recurse -File
    $PSADTDest = Get-ChildItem -Path "$RootPath\$Version" -Recurse -File
    # Avoid null a parameter error if $PSADTDest is empty
    if ($PSADTDest.Count -ne 0) {
        [System.Collections.ArrayList] $Difference = @(Compare-Object -ReferenceObject $PSADTSource -DifferenceObject $PSADTDest -Property Name)
    }
    if ($null -eq $Difference -or $Difference.Where{$_.SideIndicator -eq '<='}.Count -gt 0) {
        $PSADTAction = @{
            Name = 'PowerShell ADT'
            Source = "$Resources\PSADT\*"
            Destination = "$RootPath\$Version"
            Action = 'Copy'
        }
    }
    else {
        $PSADTAction = @{
            Name = 'PowerShell ADT'
            Action = 'None'
        }
    }
    $Actions.Add($PSADTAction) > $null

    # Copy templated Deploy-Application.ps1
    $ScriptFile = "$RootPath\$Version\Deploy-Application.ps1"
    $Template = Get-Content -Path "$Resources\Deploy-Application.ps1.template" -Raw
    $Formatted = $Template -f $FormatArray
    $Current = Get-Content -Path $ScriptFile -Raw -ErrorAction SilentlyContinue
    
    # See if a Destination file already exists
    if ($null -eq $Current -or $Current.trim() -ne $Formatted.trim()) {
        $ScriptAction = @{
            Name = 'Deploy-Application.ps1'
            Contents = $Formatted
            Destination = $ScriptFile
            Action = 'Write'
        }
    }
    else {
        $ScriptAction = @{
            Name = 'Deploy-Application.ps1'
            Action = 'None'
        }
    }
    $Actions.Add($ScriptAction) > $null

    [System.Collections.ArrayList] $Details = foreach ($Item in $Actions) {
        switch ($Item.Action) {
            'Move' {
                Move-Item -Path $Item.Source -Destination $Item.Destination -Force
                $Status = 'Success'
                $Color = $ANSI.Yellow
                break
            }

            'Copy' {
                Copy-Item -Path $Item.Source -Destination $Item.Destination -Recurse -Force
                $Status = 'Success'
                $Color = $ANSI.Yellow
                break
            }

            'Write' {
                Out-File -FilePath $Item.Destination -InputObject $Item.Contents -Force
                $Status = 'Success'
                $Color = $ANSI.Yellow
                break
            }

            default {
                $Status = 'OK'
                $Color = $ANSI.Green
            }
        }
        
        Write-Host -Object ('    - ' + $Color + $Status + ': ' + $ANSI.Reset + $Item.Name)
        Write-Output -InputObject ("$Status`: " + $Item.Name)
    }
    # Save Deploy-Application.ps1 if it does not exist or if changes were detected
    
    Complete-Phase -Status None -Details $Details
}