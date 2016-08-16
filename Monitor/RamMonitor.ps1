############################################################################################################
# Author: Adam Sulik                                                                                       #
# Date : 10/15/2014                                                                                        #
# Abstract: This script grabs the current RAM utilization and reports that to Nagios                       #
#                                                                                                          #
# Version History:                                                                                         #
#   1.0      10/15/2014       Initial Version                                                              #                                                                                                          #                                                                                                       #                                                                                                       #
#   1.5      10/26/2015       Added Parameters to script                                                   #
#                                                                                                          #
# Format to run:                                                                                           #
#   .\RamCheck.ps1 -Warning 80 -Critical 90                                                                #
#                                                                                                          #
############################################################################################################

[CmdletBinding()]
param($warning, $critical, $servername)

foreach ($server in $servername){

    $totalMemory = Get-WMIObject -ComputerName $server -class win32_physicalmemory |Measure-Object -Property capacity -sum |Select-Object Sum
    $totalMemory = $totalMemory.Sum
    #converts to MegaBytes
    $totalMemory = $totalMemory / 1048576

    $freeMemory = Get-WmiObject -ComputerName $server Win32_PerfRawData_PerfOS_Memory | Select-Object AvailableMBytes
    $freeMemory = $freeMemory.AvailableMBytes

    $utilizedMemory = $totalMemory - $freeMemory
    $percentUtilized = [decimal]::round($utilizedMemory / $totalMemory * 100,2)


    if ($percentUtilized -gt $critical){
        $msg = $msg += "$server : CRITICAL - RAM utilization is at $percentutilized%`n"
        $criticalerr = $criticalerr += 1
    } elseif($percentUtilized -gt $warning){
        $msg = $msg += "$server : WARNING - RAM utilization is at $percentutilized%`n"
        $warningerr = $warningerr += 1
    } else {
        #$msg = $msg +=  "$server : OK - RAM utilization is at $percentutilized%"
    }
}

if ($criticalerr -gt 0) {
    Write-Output $msg
    Exit(2)
} elseif ($warningerr -gt 0) {
    Write-Output $msg
    Exit(1)
} else {
    Exit
}
