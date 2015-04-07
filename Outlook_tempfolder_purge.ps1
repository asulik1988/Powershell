$a = Get-ItemProperty -Path HKCU:\SOFTWARE\MICROSOFT\OFFICE\14.0\OUTLOOK\SECURITY -Name OutlookSecureTempFolder
$a -match "@{OutlookSecureTempFolder=(?<content>.*)}"
$b = $matches['content']
$b = $b + "\*"
remove-item $b -Recurse -force
#test
