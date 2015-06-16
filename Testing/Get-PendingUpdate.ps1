$c = "a-sulik"

If (Test-Connection -ComputerName $c -Count 1 -Quiet) { 
            Try { 
            #Create Session COM object 
              #  Write-Verbose "Creating COM object for WSUS Session" 
                Write-Output "Creating COM object for WSUS Session" 
                $updatesession =  [activator]::CreateInstance([type]::GetTypeFromProgID("Microsoft.Update.Session",$c)) 
                } 
            Catch { 
              #  Write-Warning "$($Error[0])" 
                Write-Output "$($Error[0])" 
                Break 
                } 
 
            #Configure Session COM Object 
          #  Write-Verbose "Creating COM object for WSUS update Search"
            Write-Output "Creating COM object for WSUS update Search" 
            $updatesearcher = $updatesession.CreateUpdateSearcher() 
 
            #Configure Searcher object to look for Updates awaiting installation 
            #Write-Verbose "Searching for WSUS updates on client" 
            Write-Output "Searching for WSUS updates on client" 
            $searchresult = $updatesearcher.Search("IsInstalled=1")     
             
            #Verify if Updates need installed 
           # Write-Verbose "Verifing that updates are available to install"
            Write-Output "Verifing that updates are available to install"  
            If ($searchresult.Updates.Count -gt 0) { 
                #Updates are waiting to be installed 
              #  Write-Verbose "Found $($searchresult.Updates.Count) update\s!" 
                Write-Output "Found $($searchresult.Updates.Count) update\s!" 
                #Cache the count to make the For loop run faster 
                $count = $searchresult.Updates.Count 
                 
                #Begin iterating through Updates available for installation 
              #  Write-Verbose "Iterating through list of updates"
                Write-Output "Iterating through list of updates"  
                For ($i=0; $i -lt $Count; $i++) { 
                    #Create object holding update 
                    $update = $searchresult.Updates.Item($i) 
                     
                    #Verify that update has been downloaded 
                    If ($update.IsDownLoaded -eq "True") {  
                        $temp = "" | Select Computer, Title, KB,IsDownloaded 
                        $temp.Computer = $c 
                        $temp.Title = ($update.Title -split('\('))[0] 
                        $temp.KB = (($update.title -split('\('))[1] -split('\)'))[0] 
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
               # Write-Verbose "No updates to install." 
                Write-Output "No updates to install." 
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
           # Write-Warning "$($c): Offline" 
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
   