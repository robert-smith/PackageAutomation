function Get-Supersedence {
    param (
        [Microsoft.ConfigurationManagement.ManagementProvider.WqlQueryEngine.WqlResultObject]$Application
    )

    $Settings = [xml]($Application.SDMPackageXML)
    $Settings.AppMgmtDigest.DeploymentType.Supersedes.DeploymentTypeRule.DeploymentTypeIntentExpression.DeploymentTypeReference
}