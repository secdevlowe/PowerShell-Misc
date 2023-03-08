<#
    .SYNOPSIS

    .DESCRIPTION

    .PARAMETER listOfSitesToCheck

    .EXAMPLE
#>
function Get-WebsiteHTTPResponse
{
    
    Param(
        [Parameter(Mandatory=$true, HelpMessage = "Enter the full filepath and name to list containing the URLs to be used: ")] [ValidateNotNullOrEmpty()] [string]$listOfSitesToCheck
    )

    for (i=0; i<=)

    #ensure we get a response even if an error's returned
    $response = try { 
        (Invoke-WebRequest -Uri 'localhost/foo' -ErrorAction Stop).BaseResponse
    } catch [System.Net.WebException] { 
        Write-Verbose "An exception was caught: $($_.Exception.Message)"
        $_.Exception.Response 
    } 

    #then convert the status code enum to int by doing this
    $statusCodeInt = [int]$response.BaseResponse.StatusCode
    #or this
    $statusCodeInt = $response.BaseResponse.StatusCode.Value__

}