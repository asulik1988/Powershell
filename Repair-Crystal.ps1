[CmdletBinding()]
param($action)

$CrystalRasService = "BOEXI40SIAGROUSCORECRS01WUSCORED"

    if ($action -eq 'start'){
        Write-Verbose " Starting Crystal RAS"
        Start-Service $CrystalRasService
        Write-Verbose "Run '.\Repair-Crystal.ps1 -action query' to verify the service is back up"

    } elseif ($action -eq 'stop'){
        Write-Verbose " Stopping Crystal RAS"
        Stop-Service $CrystalRasService
        Write-Verbose "Run '.\Repair-Crystal.ps1 -action query' to verify the service is down"

    } elseif ($action -eq 'query'){
        Write-Verbose " Checking to see if Crystal RAS is online"
        Get-Service $CrystalRasService 

    } elseif ($action -eq 'kill') {
        Write-Verbose "Performing KILL of Crystal RAS. Grabbing PID"
        $id = Get-WmiObject Win32_Service | Where-Object {$_.name -match "$CrystalRasService"} | Select-Object -ExpandProperty ProcessID
        Write-Verbose "PID = $id Forcing Process termination now"
        Get-Process -Id $id | Stop-Process -Force
        Write-Verbose "Process successfully terminating. Now restarting"
        Write-Verbose "Run '.\Repair-Crystal.ps1 -action query' to verify the service is back up"
           
    } elseif ($action -eq 'log'){
        Write-Verbose "Grabbing Crystal Error Log content"
        gc (dir 'C:\Apps\SAP BusinessObjects\SAP BusinessObjects Enterprise XI 4.0\logging\error*' | sort LastWriteTime | select -Last 1)
        Write-Verbose "Log complete"
    } 
    
    else {
        gc Help.txt | Out-Host
    }


 