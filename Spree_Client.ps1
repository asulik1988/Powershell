$script:sqlcmd1checkin = "use XXXXXXXXXXXXXXXX; INSERT INTO tasks_servers (hostname,ip,type,parent,last_checkin) values('asulik', 'XXXXXXXXXXXXXXXX', 'CERT',''Bacon, '2014-12-18 16:23:06') ON DUPLICATE KEY UPDATE id=LAST_INSERT_ID(id),last_checkin=now()"
$script:sqlcmd2checkinrow = "use XXXXXXXXXXXXXXXX;Select id,hostname,ip,type,parent,last_checkin FROM tasks_servers Where hostname = 'asulik'"
$script:sqlcmd3tasksqueue = "use XXXXXXXXXXXXXXXX; select * from tasks_queue where id = `"$script:id`""
$script:sqlcmd4appcheck = "use XXXXXXXXXXXXXXXX; select * from tasks_profiles where id = `"$script:appnumber`""
$script:sqlcmd5queueappverprofil = "use XXXXXXXXXXXXXXXX; select * from tasks_queue q, tasks_appversions a, tasks_profiles p where q.rid_id=a.id and p.id=a.app"
$script:sqlcmd6appversions = "use XXXXXXXXXXXXXXXX; select * from tasks_appversions where id = `"$script:rid_id`""


function sqlwritetable($args1) {
[void][system.reflection.Assembly]::LoadFrom(“C:\Program Files (x86)\MySQL\MySQL Connector Net 5.0.9\Binaries\.NET 2.0\MySQL.Data.dll”)
$dbconnect = New-Object MySql.Data.MySqlClient.MySqlconnection
$dbconnect.connectionString = "server=XXXXXXXXXXXXXXXX;user id=XXXXXXXXXXXXXXXX;pwd=XXXXXXXXXXXXXXXX;database=XXXXXXXXXXXXXXXX"
if (-not ($dbconnect.State -like "Open")) { $dbconnect.Open() }
$sql = New-Object MySql.Data.MySqlclient.MySqlcommand
$sql.Connection = $dbconnect
$sql.Commandtext = $args1
   #================== This part of the function creates a dataset that gets filled in by the returned data from our Query ============###
$dataset=New-Object system.Data.Dataset
$dataAdaptor=New-Object MySql.Data.MySqlClient.MySqlDataAdapter($sql)
$dataAdaptor.fill($dataset)
$script:table = $dataset.tables[0]
$dbconnect.Close()
}

function sqlwriterow($args1, $args2) {
[void][system.reflection.Assembly]::LoadFrom(“C:\Program Files (x86)\MySQL\MySQL Connector Net 5.0.9\Binaries\.NET 2.0\MySQL.Data.dll”)
$dbconnect = New-Object MySql.Data.MySqlClient.MySqlconnection
$dbconnect.connectionString = "server=XXXXXXXXXXXXXXXX;user id=XXXXXXXXXXXXXXXX;pwd=XXXXXXXXXXXXX;database=XXXXXXXXXXXXXXXX"
if (-not ($dbconnect.State -like "Open")) { $dbconnect.Open() }
$sql = New-Object MySql.Data.MySqlclient.MySqlcommand
$sql.Connection = $dbconnect
$sql.Commandtext = $args1
   #================== This part of the function creates a dataset that gets filled in by the returned data from our Query ============###
$dataset=New-Object system.Data.Dataset
$dataAdaptor=New-Object MySql.Data.MySqlClient.MySqlDataAdapter($sql)
$dataAdaptor.fill($dataset)
$script:row = $dataset.tables[0].Rows[0].$args2
$dbconnect.Close()
}



function timer {
param ($arg)
for (;;) {
$date = Get-Date
[System.Reflection.Assembly]::LoadWithPartialName(“System.Diagnostics")
$stopwatch = new-object System.Diagnostics.Stopwatch
$stopwatch.start()
while ($stopwatch.Elapsed.Seconds -lt 2) {$null}
foreach ($element in $arg){
sqlwritetable($element)
}
Write-Output $date  " " $table  | Out-File C:\test\spree_log.txt -Append
approvalcheck
}
}




function approvalcheck(){
$date = Get-Date -Format MM-dd-yyyy
$fulldate = Get-Date

sqlwritetable -args1 "use XXXXXXXXXXXXXXXX; select * from tasks_queue  where toPath like '%\\\%'"
$i = -1
foreach ($row in $table){
$i = $i +1
$approval = $table.Rows[$i].approved
if ([int]$approval -eq "5") {
$script:id = $table.Rows[$i].id
$script:rid_id = $table.Rows[$i].rid_id
$script:env = $table.Rows[$i].env
$script:name = $table.Rows[$i].name

sqlwriterow -args1 $sqlcmd6appversions -args2 "app";$script:appnumber = $script:row
sqlwriterow -args1 $sqlcmd4appcheck -args2 "app"; $script:app = $script:row

    $len = $name.Length
    $cut = $name.Substring(0,$len - 4)
    $ext = $name.Substring($len - 4)
    $backupname = ($cut + "_" + "backup" + $ext)
$testpath = Test-Path S:\$app\$rid_id\$env\$name
if ($testpath -eq "true") {
Copy-Item S:\$app\$rid_id\$env\$name R:\$app\$rid_id\$env\$backupname
write-host $backupname
Copy-Item C:\test\$name S:\$app\$rid_id\$env
write-host C:\test\$name S:\$app\$rid_id\$env\$name
}
else {
Copy-Item C:\test\$name S:\$app\$rid_id\$env
write-host C:\test\$name S:\$app\$rid_id\$env\$name
write-output "The path $testpath has not been found. -- $fulldate"  ("-----------------------------------")  | Out-File C:\test\spree_log.txt -Append
}
}
else{
write-output "no approvals nothing to see here"  ("-----------------------------------")  | Out-File C:\test\spree_log.txt -Append
}
}
}

timer($sqlcmd1checkin, $sqlcmd2checkinrow)


