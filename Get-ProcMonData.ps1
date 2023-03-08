# Use psexec to Connect to a Remote Machine and run Process Monitor to get detailed analysis of system activity
# DMS; psexec; report; remoting; Process Monitor; procmon;

Function Wait-ProgressBar([int]$Duration, [string]$Message)
{
    $TimeToWait = 1
    while($TimeToWait -lt $Duration) 
    {
        $Remaining = $Duration - $TimeToWait
        Write-Progress $Message -Status "$Remaining seconds remaining" -PercentComplete (($TimeToWait*100)/$Duration)
        start-sleep -Seconds 1
        $TimeToWait++
    }
}

Function Get-DiskSpace([string] $Computer)
{
        try { $HD = Get-WmiObject Win32_LogicalDisk -ComputerName $Computer -Filter "DeviceID='C:'" -ErrorAction Stop } 
        catch { Write-Warning "Unable to connect to $Computer. $_"; continue}
        if(!$HD) { throw }
        $FreeSpace = [math]::round(($HD.FreeSpace/1gb),2)
        return $FreeSpace
}

Function Get-ProcMonData
{
    Param(
        [Parameter(Mandatory=$true)][string]$ComputerName, 
        [Parameter(Mandatory=$true,
            HelpMessage="Enter a duration from 10 to 100 seconds (limited due to disk space requriements")]
            [ValidateRange(10,100)][int]$Duration
    )

    $Procmon = 'procmon.exe'
    $AdminShare = 'c$'
    $LocalDrive = 'c:'
    $psexecPath = "c:\bin\pstools\psexec.exe"
    $procmonPath = "c:\bin\$Procmon"
    $TargetFolder = "windows\temp"
    $LocalTarget = "c:\temp"
    
    write-host "Verifing that the target computer responds to ping and that we have psexec and Process monitor executables" -ForegroundColor Green
    
    if(Test-Path("$LocalTarget\$ComputerName.pml")) { try { Remove-Item "$LocalTarget\$ComputerName.pml" -ErrorAction Stop} catch { Write-Warning $_.Exception; break }}
    
    if (!(Test-Connection $ComputerName -ErrorAction Stop)) { Write-Warning "Cannot ping $ComputerName"; break } 
    if (!(Test-Path $psexecPath -ErrorAction Stop)) { Write-Warning "Cannot find $psexecPath"; break }
    if (!(Test-Path $procmonPath -ErrorAction Stop)) { Write-Warning "Cannot find $procmonPath"; break }

    # Process monitor generates enormous amounts of data.  
    # To try and offer some protections, the script won't run if the source or target have less than 500MB free
    write-host "Verifying free diskspace on source and target." -ForegroundColor Green
    if((Get-DiskSpace $ComputerName) -lt 0.5) 
        { Write-Warning "$ComputerName has less than 500MB free and thus process monitor could fill the disk."; break }

    if((Get-DiskSpace $Env:ComputerName) -lt 0.5) 
        { Write-Warning "Local computer has less than 500MB free and thus process monitor could fill the disk."; break }

    Write-Host "Copying Process monitor to the target system temporarily so we can execute it locally with psexec." -ForegroundColor Green
    try { Copy-Item $procmonPath "\\$ComputerName\$AdminShare\$TargetFolder" -Force -Verbose -ErrorAction Stop } catch { Write-Warning $_.Exception; break }

    # Process monitor must be launched as a separate process otherwise the sleep and terminate commands below would never execute and fill the disk
    Write-Host "Starting process monitor on $ComputerName" -ForegroundColor Green
    Start-Process -FilePath "psexec.exe" -ArgumentList "-s -i 0 \\$ComputerName $LocalDrive\$TargetFolder\$Procmon /backingfile /accepteula $LocalDrive\$TargetFolder\$ComputerName /quiet" -PassThru | Out-null
    
    Wait-ProgressBar -Duration $Duration -Message "Waiting for procmon data collection to complete"

    Write-Host "Terminating process monitor process on $ComputerName" -ForegroundColor Green
    $Discard = & $psexecPath -s -i 0 \\$ComputerName "$LocalDrive\$TargetFolder\$Procmon" /terminate 2>&1; $Output | select -skip 1 | out-string

    Write-Host "Copy process monitor file to local machine for analysis" -ForegroundColor Green
    try { Copy-Item "\\$ComputerName\$AdminShare\$TargetFolder\$ComputerName.pml" $LocalTarget -Force -Verbose -ErrorAction Stop }
    catch { $_ ; }

    Write-Host "Remove temporary process monitor executable as well as log file from target system" -ForegroundColor Green
    Remove-Item "\\$ComputerName\$AdminShare\$TargetFolder\$ComputerName.pml" -Verbose -Force
    Remove-Item "\\$ComputerName\$AdminShare\$TargetFolder\$Procmon" -Verbose -Force

    Write-host "Launching Process Monitor and loading collected log data" -ForegroundColor Green
    if(Test-Path("$LocalTarget\$ComputerName.pml")) { & $procmonPath /openlog $LocalTarget\$ComputerName.pml }

    $FileSize = [math]::round(((Get-Item "$LocalTarget\$ComputerName.pml").Length/1mb),2)    
    Write-Warning "$LocalTarget\$ComputerName.pml is $FileSize MB. Remember to delete it when finished." 
}

Get-ProcmonData -ComputerName remotecomputerhere -Duration 20