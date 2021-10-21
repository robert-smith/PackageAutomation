function Assign {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [scriptblock] $ScriptBlock
    )

    $AssignExpanded = Expand-Placeholders -InputObject $ScriptBlock -Legend $ReplaceLegend
    $Splat = Convert-ScriptBlockToHashtable -ScriptBlock $AssignExpanded
    # Add app ID to splat ($NewApp is defined in New-IntuneApplication in the Script scope so this child function can see it)
    $Splat.ID = $IntuneAppLatest.id
    $Assignments = Get-PAIntuneWin32AppAssignment -ID $Splat.ID -WarningAction SilentlyContinue
    
    switch ($Splat.Group) {
        'AllDevices' {
            $Details = 'Install ' + $Splat.Intent + ' ->  All Devices'
            $Exists = $Assignments | Where-Object -FilterScript {$_.target.'@odata.type' -eq '#microsoft.graph.allDevicesAssignmentTarget'}
            if ($Exists) {
                $Status = 'OK'
                $Color = $ANSI.Green
                break
            }
            # Remove the Group key since there is no parameter with that name
            $Splat.Remove('Group')
            # Remove Include if it was set since it's not applicable here
            $Splat.Remove('Include')
            Add-PAIntuneWin32AppAssignmentAllDevices @Splat > $null
            $Status = 'Success'
            $Color = $ANSI.Yellow
            break
        }
        'AllUsers' {
            $Details = 'Install ' + $Splat.Intent + ' ->  All Users'
            $Exists = $Assignments | Where-Object -FilterScript {$_.target.'@odata.type' -eq '#microsoft.graph.allLicensedUsersAssignmentTarget'}
            if ($Exists) {
                $Status = 'OK'
                $Color = $ANSI.Green
                break
            }
            # Remove the Group key since there is no parameter with that name
            $Splat.Remove('Group')
            # Remove Include if it was set since it's not applicable here
            $Splat.Remove('Include')
            Add-PAIntuneWin32AppAssignmentAllUsers @Splat > $null
            $Status = 'Success'
            $Color = $ANSI.Yellow
            break
        }
        default {
            $GroupName = $Splat.Group
            $Details = 'Install ' + $Splat.Intent + ' -> ' + $GroupName
            # Get group ID since that is the only way to assign to custom groups
            $AzureGroup = Get-AzureADGroup -Filter "DisplayName eq '$GroupName'"
            if (-not $AzureGroup) {
                Write-Error -Message "The group ""$GroupName"" does not exist in Azure."
            }
            $ID = $AzureGroup.ObjectId
            $Exists = $Assignments | Where-Object -FilterScript {$_.target.groupId -eq $ID}
            if ($Exists) {
                $Status = 'OK'
                $Color = $ANSI.Green
                break
            }
            if (-not $Splat.Exclude) {
                $Splat.Include = $true
            }
            $Splat.GroupID = $ID
            # Remove the Group key since there is no parameter with that name
            $Splat.Remove('Group')
            Add-PAIntuneWin32AppAssignmentGroup @Splat > $null
            $Status = 'Success'
            $Color = $ANSI.Yellow
        }
    }

    Write-Host -Object ('    - ' + $Color + $Status + ': ' + $ANSI.Reset + $Details)
    return $Status + ': ' + $Details
}