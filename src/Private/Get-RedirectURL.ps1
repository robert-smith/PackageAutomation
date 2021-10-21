<#

.SYNOPSIS
The purpose of this function is to take a URL and return the URL that it redirects to.
This is useful with more modern applications that have a generic URL that always
redirects to the latest verion of the application. Rather than just downloading
the file every time, a version number can usually be extracted from the file name
in the redirected URL so that we can check to see if this version is already packaged.

#>

function Get-RedirectURL {
    [CmdletBinding()]
    param (
        [string]$URL
    )

    # If URL already ends with an MSI or EXE filename, then return the same URL
    if ($URL -match '(\.exe|\.msi)$') {
        return $URL
    }
    # Set https to use TLS 1.2 to avoid web request errors
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $Request = [System.Net.WebRequest]::Create($URL)
    
    # Do not keep the connection open after the response is complete
    $Request.KeepAlive = $false
    $Response = $Request.GetResponse()
    $Redirect =  $Response.ResponseUri.AbsoluteUri
    
    # Clear the web request variables and remove the from memory. Otherwise, it will result in too many
    # open connections which can cause future requests to be refused.
    Remove-Variable -Name Request, Response -Force
    [System.GC]::Collect()
    
    return $Redirect
}