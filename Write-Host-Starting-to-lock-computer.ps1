Write-Host "Starting to lock computer every 0.3 seconds for 75 times..."

for ($var = 1; $var -le 10000; $var++) {
	rundll32.exe user32.dll,LockWorkStation
	Start-Sleep -Seconds 0.7
	Write-Host $var
}
