Function Get-UserProfile
    {
    <#
        .SYNOPSIS

        .DESCRIPTION

        .EXAMPLE
    #> 

    Param(
        [Parameter(Mandatory=$true, HelpMessage = "Enter the target computer name.")] [ValidateNotNullOrEmpty()] [string]$ComputerName,
        [Parameter(Mandatory=$true, HelpMessage = "Enter the User Name")] [ValidateNotNullOrEmpty()] [string]$userName
    )

    $getUserProfile = Get-CimInstance -computername $ComputerName -Class Win32_UserProfile | select { $_.LocalPath.split('\')[-1]}


    Write-Host "`n=========================================================`nThe Profile of $userName is below`n=========================================================`n"

    Return Out-String -InputObject $getUserProfile -Width 1000


}