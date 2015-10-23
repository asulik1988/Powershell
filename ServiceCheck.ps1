#######################################################################
#+-------------------------------------------------------------------+#
#| Name: Generic Services Check for Nagios	   	                     |#
#| Author: Adam Sulik					   	                         |#
#|							   	                                     |#
#|- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -|#
#| 							    	                                 |#
#| Abstract: This check monitors a given service and reports back    |#
#|           it's state to nagios. OK if it's up and running,        |#
#|           critical if it's down, and warning if the you mispelled |#
#|           and are monitoring a service not actually on the server |#
#|							                                         |#
#|- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -|#
#|							                                         |#
#|Version History:			                     		             |#					   
#|							                                         |#
#|  1.0    10/23/2015   Initial Version		                         |#
#|                                                                   |#
#|Format to run:                                                     |#
#| .\ServiceCheck.ps1 -Service ServiceNameHere       	             |#
#|							                                         |#
#+-------------------------------------------------------------------+#
#######################################################################


[CmdletBinding()]
param($service)

$err = 3
$msg = "UNKNOWN - The service check itself has failed, and it may be up or down. Please manually check and make sure all is well"

try {
$ErrorActionPreference = "stop"
if (((Get-Service $service).Status) -eq "Running") {
    $err = 0
    $msg = "OK -  '" + $service + "' has no detected issues"
} else {
    $err = 2
    $msg = "CRITICAL!! - The monitored Service '" + $service + "'  is currently down."
}
}
catch [Microsoft.PowerShell.Commands.ServiceCommandException]{
$err = 1
$msg = "The service you are checking '" + $service + "' does not exist"
}
Finally {

Write-Host $msg
$host.SetShouldExit($err)
}
