[CmdletBinding()]
param(
    [Switch]$Install,
    [Switch]$Uninstall
    )


#### Installation and configuration of System Monitor #####
if ($Install){
    New-Item Checks -ItemType Directory
    New-Item Dependencies -ItemType Directory
    New-Item Logs -ItemType Directory
    New-Item .\Logs\Monitor -ItemType Directory
    New-Item .\Logs\Monitor\Log.txt -ItemType File
    New-Item .\Checks\Monitor.ps1 -ItemType File
    $scriptBlock | Out-File .\Checks\Monitor.ps1 -Force
}elseif ($Uninstall){
    if (test-path .\Checks){
        del .\Checks -Force -Recurse
    } else {
        write-warning "Checks directory not found"
    }
    if (Test-Path .\Dependencies){
        del .\Dependencies -Force -Recurse
    } else {
        write-warning "Dependencies directory not found"
    }
    if (Test-Path .\Logs){
        del .\Logs -Force -Recurse
    } else {
        write-warning "Logs directory not found"
    }
    Write-Host "Uninstall is now complete. If there were any errors they would of shown above."
}   



$scriptBlock = {
###### -Dependency Check- ####
if (!(test-path ..\Dependencies\Monitor\Log.txt)){New-Item ..\Dependencies\Monitor\Log.txt}

###### -Var Cleanup- ####
$Script:body = $null
$LASTEXITCODE = $null
$Script:exitCode = 0


###########  -CPU Monitor Kickoff-  ########### 
$CPUmessages = .\CPUMonitor.ps1 -warning 0 -critical 1 -servername (gc ..\Dependencies\CPUMonitor\servers.txt)
if ($LASTEXITCODE -eq 1 -or $LASTEXITCODE -eq 2){
    $body += "$CPUmessages`n"
}
Write-host "CPU " $LASTEXITCODE
if ($LASTEXITCODE -gt $exitCode){$exitCode = $LASTEXITCODE}


###########  -RAM Monitor Kickoff-  ###########
$RAMmessages = .\RAMMonitor.ps1 -warning 0 -critical 1 -servername (gc ..\Dependencies\CPUMonitor\servers.txt)
if ($LASTEXITCODE -eq 1 -or $LASTEXITCODE -eq 2){
    $body += "$RAMmessages`n"
}
Write-host "RAM" $LASTEXITCODE
if ($LASTEXITCODE -gt $exitCode){$exitCode = $LASTEXITCODE}


###########  -Email Kickoff Based on Error Level-  ###########
if ($LASTEXITCODE -eq 2){
    #Send-MailMessage -to asulik@csc.com -From noreply@csc.com -SmtpServer relay.ebnet.gdeb.com -Subject "Critical Alerts have been detected" -Body $body
    Write-host "Critical Alerts have been detected`n $body"
} elseif ($LASTEXITCODE -eq 1) {
    #Send-MailMessage -to asulik@csc.com -From noreply@csc.com -SmtpServer relay.ebnet.gdeb.com -Subject "WARNING Alerts have been detected" -Body $body 
    Write-host "Warning Alerts have been detected`n $body"
}



###### -Var Cleanup II- ########
$Script:body = $null
$LASTEXITCODE = $null
}




