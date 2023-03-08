<#
 .Synopsis

 .Description

 .Parameter targetComputerName

 .Example

 .LINK 
 https://learn.microsoft.com/en-us/powershell/scripting/learn/remoting/running-remote-commands?view=powershell-7.2
#>
Function Test-ComputerConnectionAndWinRM {
    # Parameters
    Param(
    [Parameter(Mandatory=$true, HelpMessage = "Enter the target computer name.")] [ValidateNotNullOrEmpty()] [string]$targetComputerName
    )
    
    if (!$targetComputerName) {
        $targetComputerName = Read-Host 'Input Computer Name'
    }

    foreach ($computer in $targetComputerName) {
        
        Write-Host "`n~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>`nPinging $targetComputerName`n~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>`n"
        $ping = Test-Connection $computer -Count 1 -Quiet
            if ($ping -eq $True){
                Write-Host "`n~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>`n$computer is Online`n~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>`n`n~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>`nChecking WSMAN on $computer`n~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>`n`n"

                $wsmanTest = Test-WSMan $computer -ErrorAction SilentlyContinue
                if (!$wsmanTest){
                    $loggedOnUser = Get-LoggedOnUser -ComputerName $computer -ErrorAction SilentlyContinue 
                    Write-Host "`n~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>`nWSMan avaliable on $computer. Current user logged in on $computer : $loggedOnUser`n~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>`n"
                }
            }
            else {
                Write-Host "`n~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>`n$computer is offline.`n~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>`n"
            }
        }
}