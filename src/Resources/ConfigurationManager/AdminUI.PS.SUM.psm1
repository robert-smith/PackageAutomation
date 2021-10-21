﻿Set-Alias -Name Get-CMSoftwareUpdateAutoDeploymentRuleDeployment -Value Get-CMAutoDeploymentRuleDeployment -Scope Global
Set-Alias -Name Remove-CMSoftwareUpdateAutoDeploymentRuleDeployment -Value Remove-CMAutoDeploymentRuleDeployment -Scope Global
Set-Alias -Name New-CMSoftwareUpdateAutoDeploymentRuleDeployment -Value New-CMAutoDeploymentRuleDeployment -Scope Global
Set-Alias -Name Set-CMSoftwareUpdateAutoDeploymentRuleDeployment -Value Set-CMAutoDeploymentRuleDeployment -Scope Global
Set-Alias -Name Get-CMWindowsUpgrade -Value Get-CMWindowsUpdate -Scope Global
Set-Alias -Name Set-CMWindowsServicingPlan -Value Set-CMSoftwareUpdateAutoDeploymentRule -Scope Global
Set-Alias -Name Remove-CMWindowsServicingPlan -Value Remove-CMSoftwareUpdateAutoDeploymentRule -Scope Global
Set-Alias -Name Set-CMAutoDeploymentRule -Value Set-CMSoftwareUpdateAutoDeploymentRule -Scope Global
Set-Alias -Name Get-CMAutoDeploymentRule -Value Get-CMSoftwareUpdateAutoDeploymentRule -Scope Global
Set-Alias -Name New-CMAutoDeploymentRule -Value New-CMSoftwareUpdateAutoDeploymentRule -Scope Global
Set-Alias -Name Remove-CMAutoDeploymentRule -Value Remove-CMSoftwareUpdateAutoDeploymentRule -Scope Global
Set-Alias -Name Invoke-CMSoftwareUpdateDownload -Value Save-CMSoftwareUpdate -Scope Global

# New-CMWindowsServicingPlan is just a wrapper for New-CMSoftwareUpdateAutoDeploymentRule with fewer filter parameters and a couple of extra
# calling requirements.
function New-CMWindowsServicingPlan {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter()][string]$Description,
        [Parameter(Mandatory = $true, ParameterSetName = "NewByCollectionName")][string]$CollectionName,
        [Parameter(Mandatory = $true, ParameterSetName = "NewByCollection")][Microsoft.ConfigurationManagement.ManagementProvider.IResultObject]$Collection,
        [Parameter(Mandatory = $true, ParameterSetName = "NewByCollectionId")][string]$CollectionId,
        [Parameter()][PSDefaultValue(Value = $true)][Alias("Enabled", "EnableDeployment")][bool]$Enable,
        [Parameter()][PSDefaultValue(Value = $true)][bool]$SendWakeupPacket,
        [Parameter()][PSDefaultValue(Value = [Microsoft.ConfigurationManagement.Cmdlets.Sum.Commands.VerboseLevelType]::OnlyErrorMessages)][Microsoft.ConfigurationManagement.Cmdlets.Sum.Commands.VerboseLevelType]$VerboseLevel,
        [Parameter()][string[]]$Language,
        [Parameter()][string[]]$Required,
        [Parameter()][string[]]$Title,
        [Parameter()][PSDefaultValue(Value = [Microsoft.ConfigurationManagement.Cmdlets.Sum.Commands.RunType]::RunTheRuleAfterAnySoftwareUpdatePointSynchronization)][Microsoft.ConfigurationManagement.Cmdlets.Sum.Commands.RunType]$RunType,
        [Parameter()][ValidateNotNullOrEmpty()][Microsoft.ConfigurationManagement.ManagementProvider.IResultObject]$Schedule,
        [Parameter()][bool]$UseUtc,
        [Parameter()][int]$AvailableTime,
        [Parameter()][PSDefaultValue(Value = $true)][bool]$AvailableImmediately,
        [Parameter()][Microsoft.ConfigurationManagement.Cmdlets.Sum.Commands.TimeUnitType]$AvailableTimeUnit,
        [Parameter()][bool]$DeadlineImmediately,
        [Parameter()][int]$DeadlineTime,
        [Parameter()][PSDefaultValue(Value = [Microsoft.ConfigurationManagement.Cmdlets.Sum.Commands.TimeUnitType]::Days)][Microsoft.ConfigurationManagement.Cmdlets.Sum.Commands.TimeUnitType]$DeadlineTimeUnit,
        [Parameter()][Microsoft.ConfigurationManagement.Cmdlets.Sum.Commands.UserNotificationType]$UserNotification,
        [Parameter()][bool]$AllowSoftwareInstallationOutsideMaintenanceWindow,
        [Parameter()][bool]$AllowRestart,
        [Parameter()][bool]$SuppressRestartServer,
        [Parameter()][bool]$SuppressRestartWorkstation,
        [Parameter()][bool]$WriteFilterHandling,
        [Parameter()][bool]$GenerateSuccessAlert,
        [Parameter()][PSDefaultValue(Value = 90)][int]$SuccessPercentage,
        [Parameter()][int]$AlertTime,
        [Parameter()][Microsoft.ConfigurationManagement.Cmdlets.Sum.Commands.TimeUnitType]$AlertTimeUnit,
        [Parameter()][bool]$DisableOperationManager,
        [Parameter()][bool]$GenerateOperationManagerAlert,
        [Parameter()][bool]$NoInstallOnRemote,
        [Parameter()][bool]$NoInstallOnUnprotected,
        [Parameter()][PSDefaultValue(Value = $true)][bool]$UseBranchCache,
        [Parameter()][bool]$DownloadFromMicrosoftUpdate,
        [Parameter()][bool]$AllowUseMeteredNetwork,
        [Parameter()][Alias("InputObject")][Microsoft.ConfigurationManagement.ManagementProvider.IResultObject]$DeploymentPackage,
        [Parameter()][bool]$DownloadFromInternet,
        [Parameter()][ValidateNotNullOrEmpty()][string]$Location,
        [Parameter()][PSDefaultValue(Value = [Microsoft.ConfigurationManagement.Cmdlets.Sum.Commands.DeploymentRing]::CB)][Microsoft.ConfigurationManagement.Cmdlets.Sum.Commands.DeploymentRing]$DeploymentRing,
        [Parameter()][PSDefaultValue(Value = 0)][Alias("UpdateDeploymentWaitDays")][int]$UpdateDeploymentWaitDay,
        [Parameter()][string[]]$LanguageSelection
    )

    process {
        New-CMSoftwareUpdateAutoDeploymentRule -IsServicingPlan @PsBoundParameters
    }
}

function Get-CMWindowsUpdate {
    param(
          [Parameter(ParameterSetName = "SearchByName")][SupportsWildcards()][Alias("LocalizedDisplayName")][string]$Name,
          [Parameter(ParameterSetName = "SearchById", Mandatory = $true)][Alias("CIId", "CI_ID")][int]$Id,
          [Parameter()][switch]$Fast)
    process {
        $category = Get-CMSoftwareUpdateCategory -UniqueId 'UpdateClassification:3689bdc8-b205-4af4-8d4a-a63924c5e9d5' -Fast
        Get-CMSoftwareUpdate -Category $category -IncludeUpgrades @PSBoundParameters
    }
}

function Get-CMWindowsServicingPlan {
    [CmdletBinding(DefaultParameterSetName = "SearchByNameMandatory")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "SearchByIdMandatory", Position = 0)][Alias("AutoDeploymentId")][int]$Id,
        [Parameter(ParameterSetName = "SearchByNameMandatory", Position = 0)][ValidateNotNullOrEmpty()][SupportsWildcards()][string]$Name,
        [Parameter()][switch]$Fast
        )

    process {
        Get-CMSoftwareUpdateAutoDeploymentRule -IsServicingPlan $true @PsBoundParameters
    }
}
# SIG # Begin signature block
# MIIjhAYJKoZIhvcNAQcCoIIjdTCCI3ECAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCBt+1dA1ec7YzFg
# /aWvvow81m2t8AnVrM0HZPhkbyVaIKCCDXYwggX0MIID3KADAgECAhMzAAABhk0h
# daDZB74sAAAAAAGGMA0GCSqGSIb3DQEBCwUAMH4xCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNpZ25p
# bmcgUENBIDIwMTEwHhcNMjAwMzA0MTgzOTQ2WhcNMjEwMzAzMTgzOTQ2WjB0MQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMR4wHAYDVQQDExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQC49eyyaaieg3Xb7ew+/hA34gqzRuReb9svBF6N3+iLD5A0iMddtunnmbFVQ+lN
# Wphf/xOGef5vXMMMk744txo/kT6CKq0GzV+IhAqDytjH3UgGhLBNZ/UWuQPgrnhw
# afQ3ZclsXo1lto4pyps4+X3RyQfnxCwqtjRxjCQ+AwIzk0vSVFnId6AwbB73w2lJ
# +MC+E6nVmyvikp7DT2swTF05JkfMUtzDosktz/pvvMWY1IUOZ71XqWUXcwfzWDJ+
# 96WxBH6LpDQ1fCQ3POA3jCBu3mMiB1kSsMihH+eq1EzD0Es7iIT1MlKERPQmC+xl
# K+9pPAw6j+rP2guYfKrMFr39AgMBAAGjggFzMIIBbzAfBgNVHSUEGDAWBgorBgEE
# AYI3TAgBBggrBgEFBQcDAzAdBgNVHQ4EFgQUhTFTFHuCaUCdTgZXja/OAQ9xOm4w
# RQYDVR0RBD4wPKQ6MDgxHjAcBgNVBAsTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEW
# MBQGA1UEBRMNMjMwMDEyKzQ1ODM4NDAfBgNVHSMEGDAWgBRIbmTlUAXTgqoXNzci
# tW2oynUClTBUBgNVHR8ETTBLMEmgR6BFhkNodHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20vcGtpb3BzL2NybC9NaWNDb2RTaWdQQ0EyMDExXzIwMTEtMDctMDguY3JsMGEG
# CCsGAQUFBwEBBFUwUzBRBggrBgEFBQcwAoZFaHR0cDovL3d3dy5taWNyb3NvZnQu
# Y29tL3BraW9wcy9jZXJ0cy9NaWNDb2RTaWdQQ0EyMDExXzIwMTEtMDctMDguY3J0
# MAwGA1UdEwEB/wQCMAAwDQYJKoZIhvcNAQELBQADggIBAEDkLXWKDtJ8rLh3d7XP
# 1xU1s6Gt0jDqeHoIpTvnsREt9MsKriVGKdVVGSJow1Lz9+9bINmPZo7ZdMhNhWGQ
# QnEF7z/3czh0MLO0z48cxCrjLch0P2sxvtcaT57LBmEy+tbhlUB6iz72KWavxuhP
# 5zxKEChtLp8gHkp5/1YTPlvRYFrZr/iup2jzc/Oo5N4/q+yhOsRT3KJu62ekQUUP
# sPU2bWsaF/hUPW/L2O1Fecf+6OOJLT2bHaAzr+EBAn0KAUiwdM+AUvasG9kHLX+I
# XXlEZvfsXGzzxFlWzNbpM99umWWMQPTGZPpSCTDDs/1Ci0Br2/oXcgayYLaZCWsj
# 1m/a0V8OHZGbppP1RrBeLQKfATjtAl0xrhMr4kgfvJ6ntChg9dxy4DiGWnsj//Qy
# wUs1UxVchRR7eFaP3M8/BV0eeMotXwTNIwzSd3uAzAI+NSrN5pVlQeC0XXTueeDu
# xDch3S5UUdDOvdlOdlRAa+85Si6HmEUgx3j0YYSC1RWBdEhwsAdH6nXtXEshAAxf
# 8PWh2wCsczMe/F4vTg4cmDsBTZwwrHqL5krX++s61sLWA67Yn4Db6rXV9Imcf5UM
# Cq09wJj5H93KH9qc1yCiJzDCtbtgyHYXAkSHQNpoj7tDX6ko9gE8vXqZIGj82mwD
# TAY9ofRH0RSMLJqpgLrBPCKNMIIHejCCBWKgAwIBAgIKYQ6Q0gAAAAAAAzANBgkq
# hkiG9w0BAQsFADCBiDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24x
# EDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlv
# bjEyMDAGA1UEAxMpTWljcm9zb2Z0IFJvb3QgQ2VydGlmaWNhdGUgQXV0aG9yaXR5
# IDIwMTEwHhcNMTEwNzA4MjA1OTA5WhcNMjYwNzA4MjEwOTA5WjB+MQswCQYDVQQG
# EwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwG
# A1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSgwJgYDVQQDEx9NaWNyb3NvZnQg
# Q29kZSBTaWduaW5nIFBDQSAyMDExMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIIC
# CgKCAgEAq/D6chAcLq3YbqqCEE00uvK2WCGfQhsqa+laUKq4BjgaBEm6f8MMHt03
# a8YS2AvwOMKZBrDIOdUBFDFC04kNeWSHfpRgJGyvnkmc6Whe0t+bU7IKLMOv2akr
# rnoJr9eWWcpgGgXpZnboMlImEi/nqwhQz7NEt13YxC4Ddato88tt8zpcoRb0Rrrg
# OGSsbmQ1eKagYw8t00CT+OPeBw3VXHmlSSnnDb6gE3e+lD3v++MrWhAfTVYoonpy
# 4BI6t0le2O3tQ5GD2Xuye4Yb2T6xjF3oiU+EGvKhL1nkkDstrjNYxbc+/jLTswM9
# sbKvkjh+0p2ALPVOVpEhNSXDOW5kf1O6nA+tGSOEy/S6A4aN91/w0FK/jJSHvMAh
# dCVfGCi2zCcoOCWYOUo2z3yxkq4cI6epZuxhH2rhKEmdX4jiJV3TIUs+UsS1Vz8k
# A/DRelsv1SPjcF0PUUZ3s/gA4bysAoJf28AVs70b1FVL5zmhD+kjSbwYuER8ReTB
# w3J64HLnJN+/RpnF78IcV9uDjexNSTCnq47f7Fufr/zdsGbiwZeBe+3W7UvnSSmn
# Eyimp31ngOaKYnhfsi+E11ecXL93KCjx7W3DKI8sj0A3T8HhhUSJxAlMxdSlQy90
# lfdu+HggWCwTXWCVmj5PM4TasIgX3p5O9JawvEagbJjS4NaIjAsCAwEAAaOCAe0w
# ggHpMBAGCSsGAQQBgjcVAQQDAgEAMB0GA1UdDgQWBBRIbmTlUAXTgqoXNzcitW2o
# ynUClTAZBgkrBgEEAYI3FAIEDB4KAFMAdQBiAEMAQTALBgNVHQ8EBAMCAYYwDwYD
# VR0TAQH/BAUwAwEB/zAfBgNVHSMEGDAWgBRyLToCMZBDuRQFTuHqp8cx0SOJNDBa
# BgNVHR8EUzBRME+gTaBLhklodHRwOi8vY3JsLm1pY3Jvc29mdC5jb20vcGtpL2Ny
# bC9wcm9kdWN0cy9NaWNSb29DZXJBdXQyMDExXzIwMTFfMDNfMjIuY3JsMF4GCCsG
# AQUFBwEBBFIwUDBOBggrBgEFBQcwAoZCaHR0cDovL3d3dy5taWNyb3NvZnQuY29t
# L3BraS9jZXJ0cy9NaWNSb29DZXJBdXQyMDExXzIwMTFfMDNfMjIuY3J0MIGfBgNV
# HSAEgZcwgZQwgZEGCSsGAQQBgjcuAzCBgzA/BggrBgEFBQcCARYzaHR0cDovL3d3
# dy5taWNyb3NvZnQuY29tL3BraW9wcy9kb2NzL3ByaW1hcnljcHMuaHRtMEAGCCsG
# AQUFBwICMDQeMiAdAEwAZQBnAGEAbABfAHAAbwBsAGkAYwB5AF8AcwB0AGEAdABl
# AG0AZQBuAHQALiAdMA0GCSqGSIb3DQEBCwUAA4ICAQBn8oalmOBUeRou09h0ZyKb
# C5YR4WOSmUKWfdJ5DJDBZV8uLD74w3LRbYP+vj/oCso7v0epo/Np22O/IjWll11l
# hJB9i0ZQVdgMknzSGksc8zxCi1LQsP1r4z4HLimb5j0bpdS1HXeUOeLpZMlEPXh6
# I/MTfaaQdION9MsmAkYqwooQu6SpBQyb7Wj6aC6VoCo/KmtYSWMfCWluWpiW5IP0
# wI/zRive/DvQvTXvbiWu5a8n7dDd8w6vmSiXmE0OPQvyCInWH8MyGOLwxS3OW560
# STkKxgrCxq2u5bLZ2xWIUUVYODJxJxp/sfQn+N4sOiBpmLJZiWhub6e3dMNABQam
# ASooPoI/E01mC8CzTfXhj38cbxV9Rad25UAqZaPDXVJihsMdYzaXht/a8/jyFqGa
# J+HNpZfQ7l1jQeNbB5yHPgZ3BtEGsXUfFL5hYbXw3MYbBL7fQccOKO7eZS/sl/ah
# XJbYANahRr1Z85elCUtIEJmAH9AAKcWxm6U/RXceNcbSoqKfenoi+kiVH6v7RyOA
# 9Z74v2u3S5fi63V4GuzqN5l5GEv/1rMjaHXmr/r8i+sLgOppO6/8MO0ETI7f33Vt
# Y5E90Z1WTk+/gFcioXgRMiF670EKsT/7qMykXcGhiJtXcVZOSEXAQsmbdlsKgEhr
# /Xmfwb1tbWrJUnMTDXpQzTGCFWQwghVgAgEBMIGVMH4xCzAJBgNVBAYTAlVTMRMw
# EQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVN
# aWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNp
# Z25pbmcgUENBIDIwMTECEzMAAAGGTSF1oNkHviwAAAAAAYYwDQYJYIZIAWUDBAIB
# BQCgga4wGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEO
# MAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIHV95BbjNOO0uSgMYHCVhEu4
# q2GKBeMooIp35yWUmuQRMEIGCisGAQQBgjcCAQwxNDAyoBSAEgBNAGkAYwByAG8A
# cwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20wDQYJKoZIhvcNAQEB
# BQAEggEApYewpsWbUW4Xj2Do6yBi3wEHTizi/LqH9BaueOcv1/O2vsGhUKKm+3XA
# sOhwWg1MiSLgxbdsbt3MHmktyfVW1Q2JsFIj0kjDu4mvgIqjWMgPTryt313avsbE
# qA0StCtuXsfMi9UTsKUwrCtt2lWLEislUpe/w19/hHyjAMCWT+UHIbKslfegUOBk
# +NBM9Gic89qTSpDfxQswx72Au+HZdGhmI5ELs7vcZZo35aVYzSjLfUkkWPU7vlV4
# Fcl+fh2QmowJgU6asSm1/Fx3nEkCHmEzEBNeuezrPjhPsJXsTd8V8J8LvFDDgbFp
# morm4xZeBqIknykw+wCHK742ZAK5d6GCEu4wghLqBgorBgEEAYI3AwMBMYIS2jCC
# EtYGCSqGSIb3DQEHAqCCEscwghLDAgEDMQ8wDQYJYIZIAWUDBAIBBQAwggFVBgsq
# hkiG9w0BCRABBKCCAUQEggFAMIIBPAIBAQYKKwYBBAGEWQoDATAxMA0GCWCGSAFl
# AwQCAQUABCB8czLamjSn8GEzM+qWfARUqlmOEXF7af5t/o0fLQT6qAIGX7vlIV1q
# GBMyMDIwMTIwNTA1MTI1NS41OTFaMASAAgH0oIHUpIHRMIHOMQswCQYDVQQGEwJV
# UzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UE
# ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSkwJwYDVQQLEyBNaWNyb3NvZnQgT3Bl
# cmF0aW9ucyBQdWVydG8gUmljbzEmMCQGA1UECxMdVGhhbGVzIFRTUyBFU046Rjc3
# Ri1FMzU2LTVCQUUxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZp
# Y2Wggg5BMIIE9TCCA92gAwIBAgITMwAAASroF5b4hqfvowAAAAABKjANBgkqhkiG
# 9w0BAQsFADB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4G
# A1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYw
# JAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDAeFw0xOTEyMTkw
# MTE1MDJaFw0yMTAzMTcwMTE1MDJaMIHOMQswCQYDVQQGEwJVUzETMBEGA1UECBMK
# V2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0
# IENvcnBvcmF0aW9uMSkwJwYDVQQLEyBNaWNyb3NvZnQgT3BlcmF0aW9ucyBQdWVy
# dG8gUmljbzEmMCQGA1UECxMdVGhhbGVzIFRTUyBFU046Rjc3Ri1FMzU2LTVCQUUx
# JTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2UwggEiMA0GCSqG
# SIb3DQEBAQUAA4IBDwAwggEKAoIBAQCf35WBpIXSbcUrBwbvZZlxf1F8Txey+OZx
# IZrXdNSg6LFm2PMueATe/pPQzL86k6D9/b/P2fjbRMyo/AX+REKBtf6SX6cwiXvN
# B2asqjKNKEPRLoFWOmDVTWtk9budXfeqtYRZrtXYMbfLg9oOyKQUHYUtraXN49xx
# Myr1f78BK+/wXE7sKlB6q6wYB3Pe9XqVUeKOWzSrI4pGsJjMPQ/7cq03IstxfRqv
# aRIJPBKiXznQGm5Gp7gFk45ZgYWbUYjvVtahacJ7vRualb3TSkSsUHbcTAtOKVhn
# 58cw2nO/oyKped9iBAuUEp72POLMxKccN9UFvy2n0og5gLWFh6ZvAgMBAAGjggEb
# MIIBFzAdBgNVHQ4EFgQUcPTFLXQrP64TdsvRJBOmSPTvE2kwHwYDVR0jBBgwFoAU
# 1WM6XIoxkPNDe3xGG8UzaFqFbVUwVgYDVR0fBE8wTTBLoEmgR4ZFaHR0cDovL2Ny
# bC5taWNyb3NvZnQuY29tL3BraS9jcmwvcHJvZHVjdHMvTWljVGltU3RhUENBXzIw
# MTAtMDctMDEuY3JsMFoGCCsGAQUFBwEBBE4wTDBKBggrBgEFBQcwAoY+aHR0cDov
# L3d3dy5taWNyb3NvZnQuY29tL3BraS9jZXJ0cy9NaWNUaW1TdGFQQ0FfMjAxMC0w
# Ny0wMS5jcnQwDAYDVR0TAQH/BAIwADATBgNVHSUEDDAKBggrBgEFBQcDCDANBgkq
# hkiG9w0BAQsFAAOCAQEAisA09Apx1aOOjlslG6zyI/ECHH/j04wVWKSoNStg9eWe
# sRLr5n/orOjfII/X9Z5BSAC74fohpMfBoBmv6APSIVzRBWDzRWh8B2p/1BMNT+k4
# 3Wqst3LywvH/MxNQkdS4VzaH6usX6E/RyxhUoPbJDyzNU0PkQEF/TIoBJvBRZYYb
# ENYhgdd/fcfHfdofSrKahg5zvemfQI+zmw7XVOkaGa7GZIkUDZ15p19SPkbsLS7v
# DDfF4SS0pecKqhzN66mmjL0gCElbSskqcyQuWYfuZCZahXUoiB1vEPvEehFhvCC2
# /T3/sPz8ncit2U5FV1KRQPiYVo3Ms6YVRsPX349GCjCCBnEwggRZoAMCAQICCmEJ
# gSoAAAAAAAIwDQYJKoZIhvcNAQELBQAwgYgxCzAJBgNVBAYTAlVTMRMwEQYDVQQI
# EwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3Nv
# ZnQgQ29ycG9yYXRpb24xMjAwBgNVBAMTKU1pY3Jvc29mdCBSb290IENlcnRpZmlj
# YXRlIEF1dGhvcml0eSAyMDEwMB4XDTEwMDcwMTIxMzY1NVoXDTI1MDcwMTIxNDY1
# NVowfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcT
# B1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UE
# AxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIwMTAwggEiMA0GCSqGSIb3DQEB
# AQUAA4IBDwAwggEKAoIBAQCpHQ28dxGKOiDs/BOX9fp/aZRrdFQQ1aUKAIKF++18
# aEssX8XD5WHCdrc+Zitb8BVTJwQxH0EbGpUdzgkTjnxhMFmxMEQP8WCIhFRDDNdN
# uDgIs0Ldk6zWczBXJoKjRQ3Q6vVHgc2/JGAyWGBG8lhHhjKEHnRhZ5FfgVSxz5NM
# ksHEpl3RYRNuKMYa+YaAu99h/EbBJx0kZxJyGiGKr0tkiVBisV39dx898Fd1rL2K
# Qk1AUdEPnAY+Z3/1ZsADlkR+79BL/W7lmsqxqPJ6Kgox8NpOBpG2iAg16HgcsOmZ
# zTznL0S6p/TcZL2kAcEgCZN4zfy8wMlEXV4WnAEFTyJNAgMBAAGjggHmMIIB4jAQ
# BgkrBgEEAYI3FQEEAwIBADAdBgNVHQ4EFgQU1WM6XIoxkPNDe3xGG8UzaFqFbVUw
# GQYJKwYBBAGCNxQCBAweCgBTAHUAYgBDAEEwCwYDVR0PBAQDAgGGMA8GA1UdEwEB
# /wQFMAMBAf8wHwYDVR0jBBgwFoAU1fZWy4/oolxiaNE9lJBb186aGMQwVgYDVR0f
# BE8wTTBLoEmgR4ZFaHR0cDovL2NybC5taWNyb3NvZnQuY29tL3BraS9jcmwvcHJv
# ZHVjdHMvTWljUm9vQ2VyQXV0XzIwMTAtMDYtMjMuY3JsMFoGCCsGAQUFBwEBBE4w
# TDBKBggrBgEFBQcwAoY+aHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraS9jZXJ0
# cy9NaWNSb29DZXJBdXRfMjAxMC0wNi0yMy5jcnQwgaAGA1UdIAEB/wSBlTCBkjCB
# jwYJKwYBBAGCNy4DMIGBMD0GCCsGAQUFBwIBFjFodHRwOi8vd3d3Lm1pY3Jvc29m
# dC5jb20vUEtJL2RvY3MvQ1BTL2RlZmF1bHQuaHRtMEAGCCsGAQUFBwICMDQeMiAd
# AEwAZQBnAGEAbABfAFAAbwBsAGkAYwB5AF8AUwB0AGEAdABlAG0AZQBuAHQALiAd
# MA0GCSqGSIb3DQEBCwUAA4ICAQAH5ohRDeLG4Jg/gXEDPZ2joSFvs+umzPUxvs8F
# 4qn++ldtGTCzwsVmyWrf9efweL3HqJ4l4/m87WtUVwgrUYJEEvu5U4zM9GASinbM
# QEBBm9xcF/9c+V4XNZgkVkt070IQyK+/f8Z/8jd9Wj8c8pl5SpFSAK84Dxf1L3mB
# ZdmptWvkx872ynoAb0swRCQiPM/tA6WWj1kpvLb9BOFwnzJKJ/1Vry/+tuWOM7ti
# X5rbV0Dp8c6ZZpCM/2pif93FSguRJuI57BlKcWOdeyFtw5yjojz6f32WapB4pm3S
# 4Zz5Hfw42JT0xqUKloakvZ4argRCg7i1gJsiOCC1JeVk7Pf0v35jWSUPei45V3ai
# caoGig+JFrphpxHLmtgOR5qAxdDNp9DvfYPw4TtxCd9ddJgiCGHasFAeb73x4QDf
# 5zEHpJM692VHeOj4qEir995yfmFrb3epgcunCaw5u+zGy9iCtHLNHfS4hQEegPsb
# iSpUObJb2sgNVZl6h3M7COaYLeqN4DMuEin1wC9UJyH3yKxO2ii4sanblrKnQqLJ
# zxlBTeCG+SqaoxFmMNO7dDJL32N79ZmKLxvHIa9Zta7cRDyXUHHXodLFVeNp3lfB
# 0d4wwP3M5k37Db9dT+mdHhk4L7zPWAUu7w2gUDXa7wknHNWzfjUeCLraNtvTX4/e
# dIhJEqGCAs8wggI4AgEBMIH8oYHUpIHRMIHOMQswCQYDVQQGEwJVUzETMBEGA1UE
# CBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9z
# b2Z0IENvcnBvcmF0aW9uMSkwJwYDVQQLEyBNaWNyb3NvZnQgT3BlcmF0aW9ucyBQ
# dWVydG8gUmljbzEmMCQGA1UECxMdVGhhbGVzIFRTUyBFU046Rjc3Ri1FMzU2LTVC
# QUUxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2WiIwoBATAH
# BgUrDgMCGgMVAOqy5qyh8iDD++nj5d9tcSlCd2F/oIGDMIGApH4wfDELMAkGA1UE
# BhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAc
# BgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0
# IFRpbWUtU3RhbXAgUENBIDIwMTAwDQYJKoZIhvcNAQEFBQACBQDjdYx9MCIYDzIw
# MjAxMjA1MDgzNTA5WhgPMjAyMDEyMDYwODM1MDlaMHQwOgYKKwYBBAGEWQoEATEs
# MCowCgIFAON1jH0CAQAwBwIBAAICDEIwBwIBAAICEhEwCgIFAON23f0CAQAwNgYK
# KwYBBAGEWQoEAjEoMCYwDAYKKwYBBAGEWQoDAqAKMAgCAQACAwehIKEKMAgCAQAC
# AwGGoDANBgkqhkiG9w0BAQUFAAOBgQDN1/hj3qk2Kxly93Klfljiy7UBelxUqHru
# 6OZGKShXI1wnsjGHROGpgfhypdQ5De1Rjy8S1N6fIjAtNrO/cPwOBWmTDy35c8iW
# QvBbkcs+7mQSlf725OJqbLHaoDxx+XDER8oswCpIznbBlV0/TOFNELbmqPO/mOj/
# ady2iMPjvDGCAw0wggMJAgEBMIGTMHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpX
# YXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQg
# Q29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAy
# MDEwAhMzAAABKugXlviGp++jAAAAAAEqMA0GCWCGSAFlAwQCAQUAoIIBSjAaBgkq
# hkiG9w0BCQMxDQYLKoZIhvcNAQkQAQQwLwYJKoZIhvcNAQkEMSIEIKY4PyLb7BHn
# USCWO9ZP5yIJYV7hkYGgvjyc1+guw8IdMIH6BgsqhkiG9w0BCRACLzGB6jCB5zCB
# 5DCBvQQgQ5g1hFr3On4bObeFqKOUPhTBQnGiIFeMlD+AqbgZi5kwgZgwgYCkfjB8
# MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVk
# bW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1N
# aWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMAITMwAAASroF5b4hqfvowAAAAAB
# KjAiBCDwolZiI59PiXENUEjwKkMwo7/2TvFzwpQn7p5PhSjhVjANBgkqhkiG9w0B
# AQsFAASCAQB49Z8zD0XkHum9HwTCS7jNBVS9bifoEJ76Rs2ckvgVPRIptGSI9NFF
# Z3Fe/xrOgE4jq/MrLm/H4spUSxWTyWMmj0nZ2un28GYKt+1k8ls7VKHqCWp4H8U5
# C+LvNA6DjH39B/4NaG95X0zSycNnpUi1fVes+bz3Fjz6n+wLxZeQdZjWbCb/HNOm
# GlspZr1MbohLAFLV3cgnIS10E0m58hOKNMmUHVm7PKyswZMFsHzvGR2kQI9GzGZZ
# HQ2YLVB+0eBRD3EqAzgoxwVFhbliWahOMSYYtbmKcxZJT4ZnrnlFqnSax7hm14Bx
# dLX4uWhgmmnGHBtZnCJj+3/ky0T7IGtK
# SIG # End signature block
