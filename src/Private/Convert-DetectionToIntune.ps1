function Convert-DetectionToIntune {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [Microsoft.ConfigurationManagement.Cmdlets.Common.DetectionClause[]] $Detection
    )
    foreach ($Rule in $Detection) {
        $Type = $Rule.SettingSourceType
        $Method = $Rule.MethodType

        # Operator conversion - SCCM operators are slightly different than Intune's
        $Operator = switch ($Rule.Operator) {
            'Equals' { 'equal' }
            'NotEquals' { 'notEqual' }
            'GreaterEquals' { 'greaterThanOrEqual' }
            'LessEquals' { 'lessThanOrEqual'}
            default {$Rule.Operator}
        }

        switch ($Type) {
            'File' {
                $Splat = @{
                    Path = $Rule.Setting.Path
                    FileOrFolder = $Rule.Setting.FileOrFolderName
                    Check32BitOn64System = $Rule.Setting.Is64Bit
                }
                if ($Method -eq 'Value') {
                    $DetectionType = $Rule.PropertyPath
                    $DetectionProperty = switch ($DetectionType) {
                        'DateCreated' { 'DateTimeValue' }
                        'DateModified' { 'DateTimeValue' }
                        'Version' { 'VersionValue' }
                        'Size' { 'SizeInMBValue' }
                    }
                    $Splat.$DetectionType = $true
                    $Splat.$DetectionProperty = $Rule.Constant.Value
                    $Splat.Operator = $Operator
                }
                else {
                    $Splat.Existence = $true
                    $Splat.DetectionType = 'exists'
                }

                New-PAIntuneWin32AppDetectionRuleFile @Splat
            }

            'Registry' {
                $Splat = @{
                    KeyPath = $Rule.Setting.Location
                    Check32BitOn64System = $Rule.Setting.Is64Bit
                }
                if ($Method -eq 'Value') {
                    $ValueType = $Rule.Constant.ValueType.Name
                    if ($ValueType -eq 'Int64') {
                        $ComparisonType = 'IntegerComparison'
                    }
                    else {
                        $ComparisonType = $ValueType + 'Comparison'
                    }
                    $Splat.$ComparisonType = $true
                    # Each comparison type has a matching operator and value parameter
                    $Splat."$ComparisonType`Operator" = $Operator
                    $Splat."$ComparisonType`Value" = $Rule.Constant.Value
                    $Splat.ValueName = $Rule.Setting.ValueName
                }
                else {
                    $Splat.Existence = $true
                    $Splat.DetectionType = 'exists'
                }

                New-PAIntuneWin32AppDetectionRuleRegistry @Splat
            }

            'MSI' {
                $Splat = @{
                    ProductCode = $Rule.Setting.ProductCode
                }
                if ($Method -eq 'Value') {
                    $Splat.ProductVersion = $Rule.Constant.Value
                    $Splat.ProductVersionOperator = $Operator
                }

                New-PAIntuneWin32AppDetectionRuleMSI @Splat
            }
        }
    }
}