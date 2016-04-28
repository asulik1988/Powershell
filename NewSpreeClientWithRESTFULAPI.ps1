#Log -logPath C:\users\adam.sulik\spree.log -content "!!! Script Begins" -overwrite $false

Start-Sleep -Seconds 1
#Log -logPath C:\users\adam.sulik\spree.log -content "!!! wait over" -overwrite $false


while ($true) {

    function Log($logPath, $content, $overwrite){
    # If overwrite is $TRUE the log function will overwrite, if $False it will append.
    # Only accepts boolean $True and $False.
        $now = get-date -Format g
	    if (!(Test-Path $logPath)){
		    New-Item $logPath -ItemType File
		    }
	    if ($overwrite){
		    Set-Content $logPath -Value "$now : $content"
		    }
	    else {
		    Add-Content $logPath -Value "$now : $content"
		    }	
    }
    #Log -logPath C:\users\adam.sulik\spree.log -content "!!! script body begins" -overwrite $false

    $appSpreeFolder = "\\contosoFS1\SPREE0"
    $backupSpreeFolder = "\\contosoFS1\SPREE1"
    $spreeScriptDirectory = "C:\Users\adam.sulik\Documents\GitHub\Powershell"

    function SpreeCredBuilder ($userAndPass) {
        $encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($userAndPass))
        $basicAuthValue = "Basic $encodedCreds"
        $Headers = @{
            Authorization = $basicAuthValue
        }
        return $Headers
    }

    function CheckIn {
       #Log -logPath C:\users\adam.sulik\spree.log -content "!!!Entering Checking !!!" -overwrite $false
        $creds = SpreeCredBuilder("userName:password")
        $ip = (get-netipaddress).IPAddress[5]
        $os = ((Get-WmiObject -Class Win32_OperatingSystem).name.split("|")[0].split(" ")) -join ("-")
        $pcount = (Get-WmiObject Win32_Processor).numberoflogicalprocessors
        $memory = [math]::Round((Get-WmiObject Win32_ComputerSystem).TotalPhysicalMemory / 1073741824)

        curl -Uri "http://contoso.ad.domain:8012/clientCheckIn?server=$env:ComputerName&ip=$ip&env=cert&os=$os&pcount=4&memory=$memory-GB" -Method Post -Headers $creds -Verbose
        #Log -logPath C:\users\adam.sulik\spree.log -content "!!! CheckIN complete" -overwrite $false
 
    }

    function GetServerStuff {
        $creds = SpreeCredBuilder("username:password")
        $softwareQueue = (curl -Uri "http://contoso.ad.domain:8012/getQueueServer?server=$env:ComputerName" -Method Post -Headers $creds -verbose | convertfrom-json)."release-data"
        return $softwareQueue
    }

    $creds = SpreeCredBuilder("username:password")

    #Log -logPath C:\users\adam.sulik\spree.log -content "!!!Pre Checking !!!" -overwrite $false
    CheckIn

    #Loop though each release component in the Queue
    foreach ($releaseComponent in GetServerStuff) {
    #Log -logPath C:\users\adam.sulik\spree.log -content "!!!Starting going though release component $releaseComponent[1] !!!" -overwrite $false
        $uniqueID = $releaseComponent[0]
        $filename = $releaseComponent[1]
        $appName = $releaseComponent[3]
        $releaseID = $releaseComponent[4]
        $scriptToRun = $releaseComponent[5]
        $environment = $releaseComponent[7]
        $statusCode = $releaseComponent[10]

        if ($statusCode -eq 0 ){ # 0 means it is a brand new release and needs to be validated, check to see if all files for the release exist.
            #Log -logPath C:\users\adam.sulik\spree.log -content "!!!Status code equals 0 !!!" -overwrite $false
            if (test-path $appSpreeFolder\$appName\$releaseID\$environment\$filename) {
                #Log -logPath C:\users\adam.sulik\spree.log -content "!!!Start file backup!!!" -overwrite $false
                #Since the file was verified as having existed we will back it up
                copy $appSpreeFolder\$appName\$releaseID\$environment\$filename $backupSpreeFolder\$appName\$releaseID\$environment\$filename -Force
                if (!(test-path $backupSpreeFolder\$appName\$releaseID\$environment\$filename)){
                    # //WRITE-CODE HERE TO SEND ERROR SAYING THE BACKUP FAILED\\
                    Log -logPath C:\users\adam.sulik\spree.log -content "!!!backup fAILED !!!" -overwrite $false
                }
            } else {
                # //WRITE-CODE HERE TO SEND ERROR SAYING THE FILE DOES NOT EXIST\\
                Log -logPath C:\users\adam.sulik\spree.log -content "!!!The file added to spree does not exist in spree directory !!!" -overwrite $false
            }
            $statusCode = 1 # here we update the status code to a 1
                #Log -logPath C:\users\adam.sulik\spree.log -content "!!!Status code is being updated to 1 !!!" -overwrite $false
            curl -Uri "http://contoso.ad.domain:8012/updateItem?item=$statusCode&itemNum=$uniqueID" -Method Post -Headers $creds -Verbose
         
        } #// end of status code 0 (pre validation) code

        elseif ($statusCode -eq 2) {
            #Log -logPath C:\users\adam.sulik\spree.log -content "!!!Status code equals 2 !!!" -overwrite $false
            if ($scriptToRun -like "*"){
                Log -logPath C:\users\adam.sulik\spree.log -content "!!!Script to run has been found beggining script !!!" -overwrite $false
                if ((test-path ($spreeScriptDirectory +"\"+ $scriptToRun))){
                    Start-Process powershell.exe ($spreeScriptDirectory +"\"+ $scriptToRun) -wait
                  
                } else {
                    Log -logPath C:\users\adam.sulik\spree.log -content "!!!Script to run specified in SPREE has not been found on this server !!!" -overwrite $false
                     # //"WRITE-CODE HERE SAYING THE SCRIPT THAT IS REQUESTED TO BE RUN DOES NOT EXIST IN c:\RTS\SCRIPTS\SPREE\$SCRIPTTORUN"\\
                }
             } else {
                Log -logPath C:\users\adam.sulik\spree.log -content "!!!No script has been specified to run in spree, no action will be taken !!!" -overwrite $false
                # //WRITE-CODE HERE TO SEND ERROR SAYING NO SCRIPT HAS BEEN SPECIFIED TO RUN\\
                }
        }



    } # //end of forloop though server queue

   

} # end of while loop that keeps this open













