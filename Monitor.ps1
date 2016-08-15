
$CPUmessages = .\CPUMonitor.ps1 -warning 0 -critical 1 -servername (gc ..\Dependencies\CPUMonitor\servers.txt)
if ($LASTEXITCODE -eq 1 -or $LASTEXITCODE -eq 2){
    $body += "$CPUmessages`n"
}
Write-host "CPU " $LASTEXITCODE
$RAMmessages = .\RAMMonitor.ps1 -warning 0 -critical 1 -servername (gc ..\Dependencies\CPUMonitor\servers.txt)
if ($LASTEXITCODE -eq 1 -or $LASTEXITCODE -eq 2){
    $body += "$RAMmessages`n"
}
Write-host "RAM" $LASTEXITCODE

write-host $body

$body = $null
$LASTEXITCODE = $null
