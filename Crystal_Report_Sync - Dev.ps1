#-------------------------------------------------------------------------------------------------
#  Setup to not add report to log if already in there. Work on removing from log if time matches
#
#----------------------------------------------------------------------------------------------------
$server = "contoso"

$srcDirectory = "\\$server\reports"
$tmpDirectory = "C:\RTS\Reports\Temp_Reports"
$baselineDirecoty = "C:\RTS\Reports\BaseLINE_REPORTS"
$newDirectory = "C:\RTS\Reports\Reports"
$log = "C:\RTS\Scripts\Crystal-Sync\copy.log"
$dirTrim = 3
$mailBody = "Good Morning,`r Attached you will find the report(s) that require attention.`r `r"
$rptNum = 0
$smtp = "mailserver.contoso.com"
$mailTo = "user.name@contoso.com"
$mailFrom = "noreply@contoso.com"
$logLocation = "C:\RTS\Scripts\Crystal-Sync\Crystal_Sync.txt"

Function TimeStampCompare(){
$tmp = [datetime](Get-ItemProperty -Path $args[0] -Name LastWriteTime).lastwritetime
$base = [datetime](Get-ItemProperty -Path $args[1] -Name LastWriteTime).lastwritetime
if ($tmp -eq $base){
    #same date
    return 1
}
else {
    #different date
    return 0
}
}

#Create log file if it does not exist
if (!(test-path $logLocation)){
New-Item $logLocation -ItemType File
}
". `r" | Out-File -FilePath $loglocation -Append

#Grab current log file contents
$logContents = gc $logLocation

#Copy all reports from source to New Crystal Server
robocopy /MIR $srcDirectory $tmpDirectory /LOG:$log /TEE

#Loop though tmp Directory and grab Files \ directories where they reside (We only need the State directory, and onward ie CA\Bundlereports.rpt etc..) Also Grabbing time stamp info.
gci -Recurse $tmpDirectory | Where-Object{!($_.PSIsContainer)} | select FullName| `
ForEach-Object {
    $tmpTime = [datetime](Get-ItemProperty -Path $_.FullName -Name LastWriteTime).lastwritetime
    $FullName = $_.FullName
    $reportarr =  [System.Collections.Generic.List[System.Object]] $FullName.split('\')
        #In this test case we are have 6 elements ($dirTrim) to get rid of "C:" "Users" "user.name" "Documents" "Powershell_Scripts" "Report Sync" because we only care about starting at the state level.
        for ($i=0; $i -le $dirTrim; $i++){
            $reportarr.RemoveAt(0)
         }
    $combine = @() 
        foreach ($element in $reportarr) {
             $combine += "\" + $element

        }
    $combine = $combine -join ""
    $combine = [string]$combine
    $tmp = $tmpDirectory + $combine
    $bse = $baselineDirecoty + $combine
    $new = $newDirectory + $combine
        if (!($tmp.Contains("Backup") -or $tmp.Contains("BackUp"))){ #filter out any Backup Directories
               if (!(test-path $bse)){ # Test to see if this is a newly created report that doesn't have an old one to compare a timestamp to.
              copy $tmp $bse
             #Write-Verbose "New file added to Crystal, Please open and update " $bse
         }

              if ((TimeStampCompare $tmp $bse) -eq 1 ){
             #Time Stamp matches, nothing to see here.
           } else {
                    #Update needed
                #copy $tmp $bse
                #copy $tmp $new
                if (!($logContents.Contains($new))){$new | Out-File -FilePath $logLocation -Append}
                $rptNum = $rptNum + 1
            }
            }
        
}



$mailSubject = "Todays Crystal Sync Status. There are $rptNum report(s) that require attention"
Send-MailMessage -From $mailFrom -To $mailTo -Subject $mailSubject -Body $mailBody -SmtpServer $smtp -Attachments $logLocation