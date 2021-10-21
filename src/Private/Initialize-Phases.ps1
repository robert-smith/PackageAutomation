function Initialize-Phases {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $AppName
    )

    # Initialize output object
    $Phases = [ordered]@{
        'Initialize'              = 'Initializing packaging job'
        'GetURL'                  = 'Getting latest download URL'
        'CheckVersion'            = 'Comparing latest version to current'
        'Download'                = 'Downloading new version'
        'MSIProps'                = 'Getting installer properties'
        'CopyFiles'               = 'Copying support files'
        'ConnectSCCM'             = 'Connecting to SCCM'
        'DetectionRules'          = 'Generating detection method rules'
        'NewApp'                  = 'Creating SCCM application'
        'DeploymentType'          = 'Adding deployment type'
        'Supersedence'            = 'Creating supersedence'
        'RemoveDeployments'       = 'Removing deployments for previous version'
        'Dependencies'            = 'Adding dependencies'
        'CreateCollection'        = 'Creating device collection'
        'Distribute'              = 'Distributing content'
        'Deploy'                  = 'Deploying application'
        'UpdateTaskSequences'     = 'Updating task sequences'
        'VersionCleanup'          = 'Removing old versions'
        'IntunePackage'           = 'Packaging app for Intune'
        'IntuneConnect'           = 'Connecting to Intune'
        'IntuneAdd'               = 'Creating app in Intune'
        'IntuneRemoveAssignments' = 'Removing old app assignments'
        'IntuneAssign'            = 'Assigning app in Intune'
        'IntuneVersionCleanup'    = 'Removing old Intune versions'
    }

    $PhaseObjects = foreach ($Phase in $Phases.Keys) {
        [PSCustomObject]@{
            Name = $Phase
            Description = $Phases.$Phase
            Status = 'Not run'
        }
    }

    $ResultObj = @{
        Name = $AppName
        Phases = $PhaseObjects
    }

    return $ResultObj
}