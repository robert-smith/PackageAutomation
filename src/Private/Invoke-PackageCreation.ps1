<#

.SYNOPSIS
This is the bread and butter of the module tying every command together. This will
go through all the steps to check for new versions, download new versions, copy PS
ADT files, expand placeholders, create detection methods, create the application in
SCCM, create the deployment type, supersede the previous verion if specified,
distribute the application content, create a collection, and finally deploy the
new application to the created or existing collection.

All of the steps are run in an idempotent manner, meaning they will leave exising
items unchanged no matter how many times it is run as long as the items are in their
correct state. Any setting found to be in an undesired state will be corrected. For
example, if the application already exists, this command will detect that and not
attempt to create it again. Conversely, if the application exists, but it does not
have a deployment type, it will create one with the correct settings.

#>

function Invoke-PackageCreation {
    [CmdletBinding()]
    param (
        [string]$Name,
        [string]$URL,
        [string]$Description = 'None.',
        [string]$Icon = (Resolve-Path -Path ($PackageConfigPath + '\icon.*')),
        [string]$Destination,
        [scriptblock]$Metadata = {},
        [ValidateScript({
            if ($_ -match "'") {
                throw 'InstallWelcomeParams must be wrapped in single quotes.'
            }
            else {$true}
        })]
        [string]$InstallWelcomeParams,
        [scriptblock]$PreInstall,
        [scriptblock]$Install,
        [scriptblock]$PostInstall,
        [ValidateScript({
            if ($_ -match "'") {
                throw 'UninstallWelcomeParams must be wrapped in single quotes.'
            }
            else {$true}
        })]
        [string]$UninstallWelcomeParams,
        [scriptblock]$PreUninstall,
        [scriptblock]$Uninstall,
        [scriptblock]$PostUninstall,
        [scriptblock]$SupersedeLastVersion = {},
        [bool]$RemovePreviousVersionDeployments,
        [AllowEmptyString()]
        [string[]]$Dependencies,
        [scriptblock]$Deployments,
        [int]$EstimatedRuntimeMins = 5,
        [int]$MaximumRuntimeMins = 60,
        [scriptblock]$DetectionRules,
        [string[]]$TaskSequences,
        [int]$VersionsToKeep,
        [scriptblock]$Intune
    )

    begin {
        # Complete the Initialize phase
        Complete-Phase -Status Done
    }

    process {
        $Latest = Save-LatestVersion -URL $URL -Destination $Destination -Metadata $Metadata
        $Props  = Get-InstallerProperties -Path $Latest.FullName -Metadata $Metadata
        
        $Script:ReplaceLegend = @{
            '%%APPNAME%%' = $Name
            '%%PRODUCTCODE%%' = $Props.ProductCode
            '%%VERSION%%' = $Props.Version
            '%%INSTALLERPATH%%' = "$Destination\" + $Props.Version + '\Files\' + $Latest.Name
            '%%INSTALLERNAME%%' = $Latest.Name
        }

        # Create a scriptblock rather than a hashtable at first since it's not easy to replace values in them.
        # This scriptblock will later on be converted to a hashtable once placeholders have been expanded.
        $Copy = "
            AppName = '$Name'
            RootPath = '$Destination'
            Installer = '$($Latest.FullName)'
            Version = '$($Props.Version)'
            Manufacturer = '$($Props.Manufacturer)'
            InstallWelcomeParams = '$InstallWelcomeParams'
            PreInstall = {$PreInstall}
            Install = {$Install}
            PostInstall = {$PostInstall}
            UninstallWelcomeParams = '$UninstallWelcomeParams'
            PreUninstall = {$PreUninstall}
            Uninstall = {$Uninstall}
            PostUninstall = {$PostUninstall}
        "

        $CopyExpanded = Expand-Placeholders -InputObject $Copy -Legend $ReplaceLegend
        $CopySplat = Convert-ScriptblockToHashtable -ScriptBlock $CopyExpanded
        Copy-ApplicationFiles @CopySplat

        # Remember console locaton before switching to the SCCM PS drive
        Push-Location
        Connect-SCCM

        $Detect = Invoke-DetectionRules -ScriptBlock $DetectionRules
        $Supersede = Convert-ScriptblockToHashtable -ScriptBlock $SupersedeLastVersion

        $AppSplat = @{
            ContentPath = $Destination + '\' + $Props.Version
            Name = $Name
            Manufacturer = $Props.Manufacturer
            Description = $Description
            Icon = $Icon
            DetectionRule = $Detect
            SupersedeLastVersion = $Supersede
            RemovePreviousVersionDeployments = $RemovePreviousVersionDeployments
            Deployments = $Deployments
            EstimatedRuntimeMins = $EstimatedRuntimeMins
            MaximumRuntimeMins = $MaximumRuntimeMins
            Dependencies = $Dependencies
            TaskSequences = $TaskSequences
            VersionsToKeep = $VersionsToKeep
            Intune = $Intune
        }
        Start-Phase -Phase NewApp
        New-Application @AppSplat
    }

}