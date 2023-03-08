<#
 .Synopsis
 This resets the network stack for Windows systems.

 .Description
 This cmdlet will run native Windows tools via commandline to attempt to resolve basic network problems.

 .Parameter targetComputerName
 Target computer name this will run on

 .Example
 # Running on a remote computer named DESKTOP-XXX00X0
 Reset-WindowsNetworkStack DESKTOP-XXX00X0

 .Example
 # Running a For loop against all entries found in a given txt file
 $computerList = Get-Content -Path C:\temp\computerList.txt
 Foreach $entry in computerList {
    Reset-WindowsNetworkStack $entry
 }
 
 .LINK
 > https://support.microsoft.com/en-us/help/10741/windows-10-fix-network-connection-issues
 > https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/ipconfig
 > https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/netsh


#>
Function Reset-WindowsNetworkStack {
	# Parameters
	Param(
	[Parameter(Mandatory=$true, HelpMessage = "Enter the target computer name.")] [ValidateNotNullOrEmpty()] [string]$targetComputerName
	)

	# Start
	Write-Host "`n~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>`nStarting Reset-WindowsNetworkStack Script on $targetComputerName`n~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>`n"

    # Creates a new PSSession on the target computer with custom options for timeout
	$sO = New-PSSessionOption -IdleTimeout 60000	# PSSession Options for PowerShell Session running on target computer
    $psSession = New-PSSession -ComputerName $targetComputerName -SessionOption $sO  # Creates a new PS session on target computer using previously defined options 

    # Checking session state
    if ($psSession.state -ne "Opened") { 
        Write-Host "`n`nThe session went into $($psSession.state) state! Reinitializing!`n`n"
        $psSession=New-PSSession -ComputerName $targetComputerName -SessionOption $sO
    }
    if ($psSession.state -eq "Opened") {
        Write-Host "`n`nPowerShell Session State is OPEN on $targetComputerName.`n`n"

        Write-Host "`nStarting Reset of Networkstack on $targetComputerName`n...Please WAIT..."
        Invoke-Command -Session $session -ComputerName $targetComputerName -ScriptBlock {
            cmd.exe /c ipconfig /release; ipconfig /renew ; ipconfig /flushdns; netsh int ip reset; netsh winsock reset
            cmd.exe /c shutdown /f /r /t 30 /c "Reset-WindowsNetworkStack ran on machine." /d p:4:1
        }
        Write-Host "`nThe following commands have finished running on $targetComputerName`: ipconfig /release, ipconfig /renew, netsh int ip reset, & netsh winsock reset."
        Start-Sleep -Seconds 1

        Write-Host "`nRebooting'$targetComputerName now."
        Restart-Computer -ComputerName $targetComputerName -WAIT -For PowerShell -Timeout 1200 -Delay 30
        Write-Host "$targetComputerName has finished rebooting."
        Start-Sleep -Seconds 1

        Write-Host "`nClosing PowerShell Sesssion on $targetComputerName now."
        Exit-PSSession $psSession
        Write-Host "Session State: $($psSession.state) on $targetComputerName."

    }
    else {
    	Write-Host "`n`nThe session is in a $($psSession.state) state!`n`n"
    }

    # Output script complete. 
	Write-Host "`n~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>`nReset-WindowsNetworkStack has finished running on $targetComputerName`n~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>~<>`n"

}