<#

Marks the currently running phase in the $Results script-wide variable to a success/done state
then outputs the same status to the console.

#>

function Complete-Phase {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateSet(
            'Done',
            'Success',
            'OK',
            'None'
        )]
        [String]$Status,
        [AllowNull()]
        [String[]]$Details
    )

    $Phase = Get-Phase
    if ($Status -ne 'None') {
        # If there are details, prepend them with a colon and a space
        if ($Details) {
            $Details = ': ' + $Details
        }
        $Phase.Status = $Status + $Details
    }
    else {
        # If None, only include the details since they will already include statuses
        $Phase.Status = $Details
    }

    switch ($Status) {
        'Done' { $Color = $ANSI.White }
        'Success' { $Color = $ANSI.Yellow }
        'OK' { $Color = $ANSI.Green }
        'None' { return } # Don't output a message if status is none
    }

    Write-Host -Object ($Color + "$Status" + $ANSI.Reset + $Details)
}