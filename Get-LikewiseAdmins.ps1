$Log =  Read-Host "Please enter the location you would like the log to reside"
If (!(Test-Path $Log)){New-Item $Log -ItemType directory}

Get-ADGroupMember -Server hq-ptc-dc1 -Credential trivin-prod\manager "Administrators" | ft -AutoSize | Out-File $log"\trivinProd-Administrators.txt"
Get-ADGroupMember "RTS-Windows Admins" | ForEach-Object {Get-ADUser $_ -Properties * | Select-Object Name, SamAccountName, mail, enabled, whenCreated, LastLogonDate} | ft -AutoSize | Out-File $log"\RTS-Windows Admins.txt"
Get-ADGroupMember -Server hq-tc-dc1 "Enterprise Admins" | ForEach-Object {Get-ADUser $_ -Properties * | Select-Object Name, SamAccountName, mail, enabled, whenCreated, LastLogonDate} | ft -AutoSize | Out-File $log"\trivin-EnterpiseAdmins.txt"
Get-ADUser -Server hq-ctc-dc1 "CN=Domain Manager,OU=Admins,OU=Maint,OU=Users,OU=triVIN,DC=corp,DC=trivin,DC=com" -Properties * | Select-Object Name, SamAccountName, mail, enabled, whenCreated, LastLogonDate | ft -AutoSize | Out-File $log"\trivinProd-DomainAdmins.txt"
Get-ADGroupMember -Server hq-ptc-dc1 -Credential trivin-prod\manager "CN=Domain Admins,CN=Users,DC=prod,DC=trivin,DC=com" | ForEach-Object {Get-ADUser $_ -Properties * | Select-Object Name, SamAccountName, mail, enabled, whenCreated, LastLogonDate} | ft -AutoSize | Out-File $log"\trivinProd-DomainAdmins.txt"