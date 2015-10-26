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
param($warning, $critical)

$totalMemory = Get-WMIObject -class win32_physicalmemory |Measure-Object -Property capacity -sum |Select-Object Sum
$totalMemory = $totalMemory.Sum
#converts to MegaBytes
$totalMemory = $totalMemory / 1048576

$freeMemory = Get-WmiObject Win32_PerfRawData_PerfOS_Memory | Select-Object AvailableMBytes
$freeMemory = $freeMemory.AvailableMBytes

$utilizedMemory = $totalMemory - $freeMemory
$percentUtilized = [decimal]::round($utilizedMemory / $totalMemory * 100,2)


if ($percentUtilized -gt $critical){
    $msg = "CRITICAL - RAM utilization is at " + $percentutilized + "%"
    $err = 2
} elseif($percentUtilized -gt $warning){
    $msg = "WARNING - RAM utilization is at " + $percentutilized + "%"
    $err = 1
} else {
    $msg = "OK - RAM utilization is at "  + $percentutilized + "%"
    $err = 0
}

Write-Host $msg
#$host.SetShouldExit($err)