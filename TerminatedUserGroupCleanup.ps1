$rtsCompanies = “DT Reg & Titling Solution”,”DealerTrack RTS”,”RTS – RegUSA Production”, "DT RTS – Louisiana, LLC"

$disabledUsers = (Get-ADUser -SearchBase "OU=Disabled Users,DC=dt,DC=inc" -Filter {enabled -eq $false} -Properties Company | `
where {$_.Company -in $rtsCompanies})

#Log Formatting
$logLocation = Read-Host "Please enter where to save log.. example: C:\DisabledUsers.txt"
$Title = "Dealertrack RTS Disabled User Cleanup"
$space = "                                                                           "
$tab = "     "
$Title | Out-File $logLocation
$space | Out-File $logLocation -Append


foreach ($user in $disabledUsers){
$date = Get-Date
$user.Name + “ “ + $date | Out-File $logLocation -Append
Get-ADPrincipalGroupMembership -Identity $user | ForEach-Object {
if ($_.distinguishedName.contains("OU=Groton,DC=dt,DC=inc" -or "OU=Metairie,DC=dt,DC=inc")){
    $tab + $_.Name | Out-File $logLocation -Append
    Write-host $user": " + $_
    Remove-ADPrincipalGroupMembership -Identity $user -MemberOf $_ -Confirm:$True}
}
}  

