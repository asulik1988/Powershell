#####################################################################################
#+---------------------------------------------------------------------------------+#
#| Name: Generic File Share Check for Nagios   	                                   |#
#| Author: Adam Sulik					   	                                       |#
#|							   	                                                   |#
#|- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -|#
#| 							    	                                               |#
#| Abstract: This check monitors a user supplied collection of shared folders      |#
#|                                                                                 |#
#|							                                                       |#
#|- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -|#
#|							                                                       |#
#|Version History:			                     	            	               |#					   
#|							                                                       |#
#|  1.0    11/06/2015   Initial Version		                                       |#
#|                                                                                 |#
#|Format to run:                                                                   |#
#| .\Shared_Folder_Monitor.ps1 -Shares "C:\share1", "C:\stuff\share2", "D:\share3" |#
#|							                                                       |#
#+---------------------------------------------------------------------------------+#
#####################################################################################

[CmdletBinding()]
param($Shares)
$err = 3
$msg = "Unknown - The Script has failed. Please manually check file shares to be sure all is well"

$smb = (Get-SmbShare | select path).path

$errVal = 0
$msgVal = @()

foreach ($share in $shares){
    if (!($smb -contains $share)){
        $msgVal += $share+","
        $errVal = $errVal + 1
    }
}

if ($errVal -gt 0){
    $err = 2
    $msg = "CRITICAL - The following Share(s) is/are not published: $msgVal"
} else {
    $err = 0
    $msg = "OK - All monitored shares are available"
}

write-host $msg
$host.SetShouldExit($err)