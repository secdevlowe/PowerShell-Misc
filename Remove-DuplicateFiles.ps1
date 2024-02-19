# Define source directory
$srcDir = "D:\ISO Files"
# Permanently delete duplicate files; use with caution
Get-ChildItem -Path $srcDir -File -Recurse | group -Property Length | where { $_.Count -gt 1 } `
        | select -ExpandProperty Group | Get-FileHash | group -Property Hash `
        | where { $_.Count -gt 1 }| foreach { $_.Group | select -Skip 1 } `
        | Remove-Item -Force -Verbose
