##############################################################################################################
# Author: Adam Sulik                                                                                         #
# Date : 08/12/2016                                                                                          #
# Abstract: This script grabs the cpu load (percentage of load) and averages it out over                     #
#           5 minutes. A scheduled task will run this script every 90 seconds so what we do is check the cpu #
#           over a 30 second window 4 times and output those values to a log. Then we go average out the     #
#           last 12 lines in the log (which equates to 4.5 minutes of averages) and based on the load        #
#           lets the monitor know if there is a problem.                                                     #
#                                                                                                            #
##############################################################################################################
[CmdletBinding()]
param($warning, $critical, $servername)
$critical = 0
$warning = 0

function Main {
    foreach ($server in $servername) {
        VerifyDependencies
        $filePath = "..\Logs\CPUMonitor\$server.txt"
        $linesToCheck = 12
        if (-not (Test-Path $filePath)){
                New-Item $filePath -ItemType file
            }
        PollCPU(.5)
        ExitAlert
    }
        write-host "top Critical = $criticalerr"
        write-host "top Warning = $warningerr"
    if ($criticalerr -gt 0){
            exit (2)
        } elseif ($warningerr -gt 0){
            exit (1)
        } else {
            exit (0)
        }
}

function VerifyDependencies {
 $logDir = (((Get-Item ..\).fullName) + "\logs")
    if (!(test-path $logDir)){
        write-warning "CPUMONITOR CHECK ERROR - The directory $logdir does not exist. Please verify the monitor has been installed correctly. "
        exit
        }

    if (!(test-path "$logDir\CPUMonitor")){New-Item "$logDir\CPUMonitor" -ItemType Directory}

    $DependenciesDir = (((Get-Item ..\).fullName) + "\Dependencies")
    if (!(test-path $DependenciesDir)){
        write-warning "CPUMONITOR CHECK ERROR - The directory $DependenciesDir does not exist. Please verify the monitor has been installed correctly. "
        Exit
        }
    if (!(Test-Path ("$DependenciesDir\CPUMonitor"))){New-Item "$DependenciesDir\CPUMonitor" -ItemType Directory}
}

function PollCPU($time) {
    for($i=0;$i-lt4;$i++){
        (Get-WmiObject -computername $server win32_processor | Measure-Object -property LoadPercentage -Average).Average|Out-File -FilePath $filePath -Append
        start-sleep -Seconds ($time) -ErrorAction SilentlyContinue
        }
}

function FileLength([string]$arg1) {
    $lines = Get-Content -Path $arg1 |Measure-Object -Line
    $lines = $lines.Lines
    return $lines
}

# This Average function first checks to see if there are proper amount of values to check agains (in this case it would
    # be 12 (which is a 4.5 minute span) if there are less than that (probably first time being run and the file was just
    # created. It will quickly run the Poll CPU function and recursivly run itself checking again to see if the correct
    # number of lines are present, and continue until there are 12 lines.
    # if / when the correct number of lines are there we grab the contents of the log file, and average the last 12 lines
    # returning that value

    function Average{
        if ((FileLength($filePath)) -lt $linesToCheck) {
            PollCPU
            Average
        }else{
        
            $dataDump = Get-Content -Path $filePath | select -Last $linesToCheck
            $sum = 0
            foreach($item in $dataDump){
                $sum = $sum + $item
            }
            $ave = $sum / $linesToCheck
            return $ave
         }
    }

    # We only need X number of lines (in our case 12) in the log, since we don't want it to become bloated
    # the cleanlog function grabs the log data and grabs the last X number of lines then overwrites it with 
    # those values. This effectly clears out old data from the log
    function CleanLog {
        $dataDump = Get-Content -Path $filePath | select -Last $linesToCheck
        $dataDump | Out-File -FilePath $filePath
    }

    # Here we check to see if the log file is more than x number of lines and if so cleans the log.
    # next we just check to see if the average load is at a certain value we exit out accordingly
    # letting us know the CPU's average state over the past couple minutes.
    function exitAlert {
        $averageValue = Average
        $averageValue = [decimal]::round($averageValue,2)
        if ((FileLength($filePath)) -gt $linesToCheck){
            CleanLog
        }
        if (($averageValue) -ge $critical){
            Write-Output "$Server - Critical - CPU load is at $averagevalue% utilization"
            #Send-MailMessage -to asulik@csc.com -From noreply@csc.com -SmtpServer relay.ebnet.gdeb.com -Subject $msg -Body "$msg `n Please investigate this CRITICAL issue."
           $criticalerr += 1
        } 
        elseif(($averageValue) -ge $warning){
            write-output "$Server - Warning - CPU load is at $averagevalue% utilization"
            $warningerr += 1
            #Send-MailMessage -to asulik@csc.com -From noreply@csc.com -SmtpServer relay.ebnet.gdeb.com -Subject $msg -Body "$msg `n Please investigate this issue."
        } else {
            $msg = "OK - CPU load is at " + $averagevalue + "% utilization"
            $err = 0
        }
        write-host "end Critical = $criticalerr"
        write-host "end Warning = $warningerr"
        
        
    }


Main
