$c = read-host "Please enter Prod box to check for pending updates"
$cert = read-host "Please enter Cert / Test box to verifiy updates against Prod"



 If (Test-Connection -ComputerName $cert -Count 1 -Quiet) {
 $report = @()
 If (-Not (Test-Path -Path "C:\users\adam.sulik\desktop\prod.txt")) {New-Item -ItemType file -Path C:\users\adam.sulik\desktop\prod.txt} 
            Try { 
            #Create Session COM object 
                Write-Output $cert " Creating COM object for WSUS Session" 
                $updatesession =  [activator]::CreateInstance([type]::GetTypeFromProgID("Microsoft.Update.Session",$cert)) 
                } 
            Catch { 
                Write-Output $cert " $($Error[0])" 
                Break 
                } 
 
            #Configure Session COM Object 
            Write-Output $cert " Creating COM object for WSUS update Search" 
            $updatesearcher = $updatesession.CreateUpdateSearcher() 
 
            #Configure Searcher object to look for Updates awaiting installation  
            Write-Output $cert " Searching for WSUS updates on client" 
            $searchresult = $updatesearcher.Search("IsInstalled=1")     
             
            #Verify if Updates need installed 
            Write-Output $cert " Verifing that updates are available to install"  
            If ($searchresult.Updates.Count -gt 0) { 
                #Updates are waiting to be installed 
                Write-Output $cert "Found $($searchresult.Updates.Count) update\s!" 
                #Cache the count to make the For loop run faster 
                $count = $searchresult.Updates.Count 
                 
                #Begin iterating through Updates available for installation 
                Write-Output "Iterating through list of updates"  
                For ($i=0; $i -lt $Count; $i++) { 
                    #Create object holding update 
                    $update = $searchresult.Updates.Item($i)                    
                        $temp = "" | Select Computer, Title, KB,IsDownloaded 
                        $temp.Computer = $cert 
                        $temp.Title = ($update.Title -split('\('))[0] 
                        $temp.KB = (($update.title -split('\('))[1] -split('\)'))[0] 
                        $temp.IsDownloaded = "True" 
                        $report += $temp                
                      } 
                      } 
            Else { 
                #Nothing to install at this time 
                Write-Output "No installed updates detected. Something is wrong." 
                #Create Temp collection for report 
                $temp = "" | Select Computer, Title, KB,IsDownloaded 
                $temp.Computer = $cert 
                $temp.Title = "NA" 
                $temp.KB = "NA" 
                $temp.IsDownloaded = "NA" 
                $report += $temp 
                } 
            } 
        Else { 
            #Nothing to install at this time 
            Write-Output "$($cert): Offline" 
            #Create Temp collection for report 
            $temp = "" | Select Computer, Title, KB,IsDownloaded 
            $temp.Computer = $cert 
            $temp.Title = "NA" 
            $temp.KB = "NA" 
            $temp.IsDownloaded = "NA" 
            $report += $temp             
            }   

    Write-Output $report
    Write-Output $report | Out-File C:\users\adam.sulik\desktop\cert.txt

If (Test-Connection -ComputerName $c -Count 1 -Quiet) {
$report = @() 
If (-Not (Test-Path -Path "C:\prod.txt")) {New-Item -ItemType file -Path C:\users\adam.sulik\desktop\prod.txt}
            Try { 
            #Create Session COM object 
              #  Write-Verbose "Creating COM object for WSUS Session" 
                Write-Output $c " Creating COM object for WSUS Session" 
                $updatesession =  [activator]::CreateInstance([type]::GetTypeFromProgID("Microsoft.Update.Session",$c)) 
                } 
            Catch { 
              #  Write-Warning "$($Error[0])" 
                Write-Output "$($Error[0])" 
                Break 
                } 
 
            #Configure Session COM Object 
            Write-Output $c " Creating COM object for WSUS update Search" 
            $updatesearcher = $updatesession.CreateUpdateSearcher() 
 
            #Configure Searcher object to look for Updates awaiting installation 
            Write-Output $c " Searching for WSUS updates on client" 
            $searchresult = $updatesearcher.Search("IsInstalled=0")     
             
            #Verify if Updates need installed 
            Write-Output $c " Verifing that updates are available to install"  
            If ($searchresult.Updates.Count -gt 0) { 
                #Updates are waiting to be installed 
              #  Write-Verbose "Found $($searchresult.Updates.Count) update\s!" 
                Write-Output "Found $c $($searchresult.Updates.Count) update\s!" 
                #Cache the count to make the For loop run faster 
                $count = $searchresult.Updates.Count 
                 
                #Begin iterating through Updates available for installation 
                Write-Output $c " Iterating through list of updates"  
                For ($i=0; $i -lt $Count; $i++) { 
                    #Create object holding update 
                    $update = $searchresult.Updates.Item($i) 
                     
                    #Verify that update has been downloaded 
                    If ($update.IsDownLoaded -eq "True") {
                        
                        $kbRow = $null
                        $KbRow = Get-Content C:\users\adam.sulik\desktop\cert.txt | Where-Object {$_ -like "*$KB*"}  
                        $temp = "" | Select Computer, Title, KB,IsDownloaded, Approved
                        if ($kbRow -eq $null){$temp.approved = "FALSE"} else {$temp.approved = "TRUE"}
                        $temp.Computer = $c 
                        $temp.Title = ($update.Title -split('\('))[0] 
                        $temp.KB = (($update.title -split('\('))[1] -split('\)'))[0] 
                        $KB = $temp.KB
                        $temp.IsDownloaded = "True" 
                        $report += $temp
                            
                        } 
                    Else { 
                        $temp = "" | Select Computer, Title, KB,IsDownloaded 
                        $temp.Computer = $c 
                        $temp.Title = ($update.Title -split('\('))[0] 
                        $temp.KB = (($update.title -split('\('))[1] -split('\)'))[0] 
                        $temp.IsDownloaded = "False" 
                        $report += $temp 
                        } 
                    } 
                 
                } 
            Else { 
                #Nothing to install at this time 
                Write-Output $c " No updates to install." 
                #Create Temp collection for report 
                $temp = "" | Select Computer, Title, KB,IsDownloaded 
                $temp.Computer = $c 
                $temp.Title = "NA" 
                $temp.KB = "NA" 
                $temp.IsDownloaded = "NA" 
                $report += $temp 
                } 
            } 
        Else { 
            #Nothing to install at this time  
            Write-Output "$($c): Offline" 
            #Create Temp collection for report 
            $temp = "" | Select Computer, Title, KB,IsDownloaded 
            $temp.Computer = $c 
            $temp.Title = "NA" 
            $temp.KB = "NA" 
            $temp.IsDownloaded = "NA" 
            $report += $temp             
            } 
   

    Write-Output $report
    Write-Output $report | Out-File C:\users\adam.sulik\desktop\prod.txt





    

