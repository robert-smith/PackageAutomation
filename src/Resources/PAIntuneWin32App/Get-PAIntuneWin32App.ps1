function Get-PAIntuneWin32App {
    <#
    .SYNOPSIS
        Get all or a specific Win32 app by either DisplayName or ID.

    .DESCRIPTION
        Get all or a specific Win32 app by either DisplayName or ID.

    .PARAMETER DisplayName
        Specify the display name for a Win32 application.

    .PARAMETER ID
        Specify the ID for a Win32 application.

    .NOTES
        Author:      Nickolaj Andersen
        Contact:     @NickolajA
        Created:     2020-01-04
        Updated:     2020-01-20

        Version history:
        1.0.0 - (2020-01-04) Function created
        1.0.1 - (2020-01-20) Updated to load all properties for objects return and support multiple objects returned for wildcard search when specifying display name
    #>
    [CmdletBinding(SupportsShouldProcess = $true, DefaultParameterSetName = "Default")]
    param(
        [parameter(Mandatory = $true, ParameterSetName = "DisplayName", HelpMessage = "Specify the display name for a Win32 application.")]
        [ValidateNotNullOrEmpty()]
        [string]$DisplayName,

        [parameter(Mandatory = $true, ParameterSetName = "ID", HelpMessage = "Specify the ID for a Win32 application.")]
        [ValidateNotNullOrEmpty()]
        [string]$ID 
    )
    Begin {
        # Ensure required auth token exists
        if ($Global:AuthToken -eq $null) {
            Write-Warning -Message "Authentication token was not found, use Connect-PAMSIntuneGraph before using this function"; break
        }
        else {
            $AuthTokenLifeTime = ($Global:AuthToken.ExpiresOn.datetime - (Get-Date).ToUniversalTime()).Minutes
            if ($AuthTokenLifeTime -le 0) {
                Write-Verbose -Message "Existing token found but has expired, use Connect-PAMSIntuneGraph to request a new authentication token"; break
            }
            else {
                Write-Verbose -Message "Current authentication token expires in (minutes): $($AuthTokenLifeTime)"
            }
        }

        # Set script variable for error action preference
        $ErrorActionPreference = "Stop"
    }
    Process {
        switch ($PSCmdlet.ParameterSetName) {
            "DisplayName" {
                Write-Verbose -Message "Attempting to retrieve all mobileApps resources to determine ID of Win32 app"
                $Win32AppList = New-Object -TypeName System.Collections.ArrayList
                $MobileApps = Invoke-IntuneGraphRequest -APIVersion "Beta" -Resource "mobileApps" -Method "GET"
                if ($MobileApps.value.Count -ge 1) {
                    Write-Verbose -Message "Filtering query response for mobileApps matching type '#microsoft.graph.win32LobApp'"
                    $Win32MobileApps = $MobileApps.value | Where-Object { $_.'@odata.type' -like "#microsoft.graph.win32LobApp" }
                    if ($null -ne $Win32MobileApps) {
                        Write-Verbose -Message "Filtering for Win32 apps matching displayName: $($DisplayName)"
                        $Win32MobileApps = $Win32MobileApps | Where-Object { $_.displayName -like "*$($DisplayName)*" }
                        if ($null -ne $Win32MobileApps) {
                            foreach ($Win32MobileApp in $Win32MobileApps) {
                                Write-Verbose -Message "Querying for Win32 app using ID: $($Win32MobileApp.id)"
                                $Win32App = Invoke-IntuneGraphRequest -APIVersion "Beta" -Resource "mobileApps/$($Win32MobileApp.id)" -Method "GET"
                                $Win32AppList.Add($Win32App) | Out-Null
                            }

                            # Handle return value
                            return $Win32AppList
                        }
                        else {
                            Write-Warning -Message "Query for Win32 app returned an empty result, no apps matching the specified search criteria was found"
                        }
                    }
                    else {
                        Write-Warning -Message "Query for Win32 apps returned an empty result, no apps matching type 'win32LobApp' was found in tenant"
                    }
                }
            }
            "ID" {
                Write-Verbose -Message "Querying for Win32 apps matching id: $($ID)"
                $Win32App = Invoke-IntuneGraphRequest -APIVersion "Beta" -Resource "mobileApps/$($ID)" -Method "GET"

                # Handle return value
                return $Win32App
            }
            default {
                Write-Verbose -Message "Querying for all Win32 apps"
                $Win32AppList = New-Object -TypeName System.Collections.ArrayList
                $Win32MobileApps = (Invoke-IntuneGraphRequest -APIVersion "Beta" -Resource "mobileApps?`$filter=isof('microsoft.graph.win32LobApp')" -Method "GET").value
                if ($Win32MobileApps.Count -ge 1) {
                    foreach ($Win32MobileApp in $Win32MobileApps) {
                        Write-Verbose -Message "Querying explicitly to retrieve all properties for Win32 app with ID: $($Win32MobileApp.id)"
                        $Win32App = Invoke-IntuneGraphRequest -APIVersion "Beta" -Resource "mobileApps/$($Win32MobileApp.id)" -Method "GET"
                        $Win32AppList.Add($Win32App) | Out-Null
                    }
                    
                    # Handle return value
                    return $Win32AppList
                }
                else {
                    Write-Warning -Message "Query for Win32 apps returned an empty result, no apps matching type 'win32LobApp' was found in tenant"
                }
            }
        }
    }
}
