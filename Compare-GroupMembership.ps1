param($user1, $user2)

$user1Groups = @()
$user2Groups = @()
$user1Diff = @()
$user2Diff = @()

function Compare-Groups ($group1, $group2) {
$Diff = @()
foreach ($object in $group1){
if (!($group2.Contains($object))) {
    $Diff += $object + ",`n"
        }
    }
return $Diff
}

foreach ($object in (Get-ADPrincipalGroupMembership -Identity $user1 | Select-Object -ExpandProperty name)) {$user1Groups += $object}
foreach ($object in (Get-ADPrincipalGroupMembership -Identity $user2 | Select-Object -ExpandProperty name)) {$user2Groups += $object}

$user1Diff = Compare-Groups -group1 $user1Groups -group2 $user2Groups
$user2Diff = Compare-Groups -group1 $user2Groups -group2 $user1Groups

Write-Host "Groups that $user1 is in and NOT $user2 :`n $user1Diff "
Write-Host "Groups that $user2 is in and NOT $user1 :`n $user2Diff "