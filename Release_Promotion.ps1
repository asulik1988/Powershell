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


$appSpreeFolder = "\\contosoFS1\SPREE0"
$backupSpreeFolder = "\\contosoFS1\SPREE1"

#Log -logPath C:\users\adam.sulik\spree.log -content "!!! Beginning Release Promotion Script !!!" -overwrite $false

function SpreeCredBuilder ($userAndPass) {
    $encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($userAndPass))
    $basicAuthValue = "Basic $encodedCreds"
    $Headers = @{
        Authorization = $basicAuthValue
    }
    return $Headers
}

function GetServerStuff {
    $creds = SpreeCredBuilder("username:password")
    $softwareQueue = (curl -Uri "http://contoso.ad.domain:8012/getQueueServer?server=$env:ComputerName" -Method Post -Headers $creds -verbose | convertfrom-json)."release-data"
    return $softwareQueue
}

#Loop though each release component in the Queue
$creds = SpreeCredBuilder("username:password")
foreach ($releaseComponent in GetServerStuff) {
#Log -logPath C:\users\adam.sulik\spree.log -content "!!!Release Promotion: Starting going though release component $releaseComponent[1] !!!" -overwrite $false
    $uniqueID = $releaseComponent[0]
    $filename = $releaseComponent[1]
    $copyToPath = $releaseComponent[2]
    $appName = $releaseComponent[3]
    $releaseID = $releaseComponent[4]
    $scriptToRun = $releaseComponent[5]
    $environment = $releaseComponent[7]
    $statusCode = $releaseComponent[10]

    #Log -logPath C:\users\adam.sulik\spree.log -content "!!!Release Promotion: Starting going though release component $releaseComponent[1] !!!" -overwrite $false

    if ($statusCode -eq 2 ){ # 2 means the release is approved and ready to continue
      Log -logPath C:\users\adam.sulik\spree.log -content "!!!Release Promotion: Status code equals 2 !!!" -overwrite $false
        if ((test-path $appSpreeFolder\$appName\$releaseID\$environment\$filename) -and (test-path $backupSpreeFolder\$appName\$releaseID\$environment\$filename)) {
            copy $appSpreeFolder\$appName\$releaseID\$environment\$filename $copyToPath\$filename -Force
            if (!(test-path $copyToPath\$filename)){
               Log -logPath C:\users\adam.sulik\spree.log -content "!!!Release Promotion: Error copying file to server !!!" -overwrite $false # // WRITE-CODE HERE TO SEND ERROR SAYING COPY TO SERVER FAILED \\
            } else {
                $statusCode = 3 # here we update the status code to a 3 signifying the release is complete
                curl -Uri "http://contoso.ad.domain:8012/updateItem?item=$statusCode&itemNum=$uniqueID" -Method Post -Headers $creds -Verbose 
            }
        } else {
            if (!(test-path $appSpreeFolder\$appName\$releaseID\$environment\$filename)) {
           Log -logPath C:\users\adam.sulik\spree.log -content "!!!Release Promotion:  FILE NAME NOT FOUND !!!" -overwrite $false # // WRITE-CODE HERE TO SEND ERROR SAYING $fILENAME NOT FOUND \\
            }
            if (!(test-path $backupSpreeFolder\$appName\$releaseID\$environment\$filename )){
                copy $backupSpreeFolder\$appName\$releaseID\$environment\$filename
                if (!(test-path $backupSpreeFolder\$appName\$releaseID\$environment\$filename)){
                    Log -logPath C:\users\adam.sulik\spree.log -content "!!!Release Promotion : Backup FAILED !!!" -overwrite $false # //WRITE-CODE HERE TO SEND ERROR SAYING THE BACKUP FAILED\\
                 }
            }
        }
        


    }
} # //end of forloop though server queue