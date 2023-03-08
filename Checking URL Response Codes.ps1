#Checking URL response codes
#Get a list of URLs from File
#Windows DialogBox for getting the file
Function Get-FileName($initialDirectory)
{   
 [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") |
 Out-Null

 $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
 $OpenFileDialog.initialDirectory = $initialDirectory
 $OpenFileDialog.filter = "All files (*.*)| *.*"
 $OpenFileDialog.ShowDialog() | Out-Null
 $OpenFileDialog.filename
} #end function Get-FileName

clear
Write-Host "Please select the input CSV file"
$myfile=Get-FileName -initialDirectory "c:"
$inputcsv = Import-Csv $myfile
#Asking for NT Credentials
Write-Host "Input your credentials for accessing the sites"
$cred=Get-Credential
#Resetting counter
$report=@()
#Looping through CSV lines
foreach ($line in $inputcsv.url)
{

function Get-UrlStatusCode([string] $line)
{
    try
    {
    # Enabling SSL/TLS
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        (Invoke-WebRequest -Uri $line -credential $cred -UseBasicParsing -DisableKeepAlive).StatusCode
    }
    catch [Net.WebException]
    {
        [int]$_.Exception.Response.StatusCode
    }
}
$statuscode = Get-UrlStatusCode $line
#Building table
$myobject=New-Object System.Object
$myobject | Add-Member -type NoteProperty -Name Url -Value $line
$myobject | Add-Member -type NoteProperty -Name Status -Value $statuscode
$report += $myObject 

Write-Host $statuscode

}
#Getting save folder dialogs

Function dialog-Folder(){
    $FolderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog -Property @{
        Description = "Please select the folder"
        RootFolder  = "Desktop"
}
    [void]$FolderBrowser.ShowDialog()
    $FolderBrowser.SelectedPath}

$folderpath = dialog-Folder

If ($folderpath){
    Write-Host 'folder found'
}
Else {
    #[System.Windows.Forms.MessageBox]::Show("No folder chosen!", "Error", 0, [System.Windows.Forms.MessageBoxIcon]::Error)
    #exit
    Write-Host 'no folder'
}
#Final Save
Write-Host "Select the folder to save to"
dialog-Folder
$savefile=read-host "Enter filename.csv for the report to be saved"
$savetofinal=$folderpath+"\"+"$savefile"
Write-Host "File will be saved to: "$savetofinal
$report | Export-Csv -Path $savetofinal