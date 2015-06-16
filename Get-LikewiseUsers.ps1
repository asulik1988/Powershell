$likewiseGroups = "RTS-CVS Users", "RTS-Accounting", "RTS-Engineering-Dev", "RTS-Engineering-Ops", "RTS-InsideSales", "RTS-IT", "RTS-Linux_Wheel", "RTS-LW_CA-Office", "RTS-LW_CustomerSupport", "RTS-QA"
$Log =  Read-Host "Please enter the location you would like the log to reside"
If (!(Test-Path $Log)){New-Item $Log -ItemType directory}
ForEach ($group in $likewiseGroups){
Get-ADGroupMember $group | ForEach-Object {Get-ADUser $_ -Properties * | Select-Object Name, SamAccountName, mail, enabled, whenCreated, LastLogonDate} | Sort-Object | ft -AutoSize | Out-file $Log\$group.txt
}