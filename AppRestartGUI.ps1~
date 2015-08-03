[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")  

$Form = New-Object System.Windows.Forms.Form    
$Form.Size = New-Object System.Drawing.Size(600,400)  

############################################## Start function

function tomcatStartStop($arg1) {
$instanceName=$DropDownBox.SelectedItem.ToString()
$env:CATALINA_BASE=C:\Apps\Tomcat\$instanceName
cd $env:CATALINA_HOME\bin
$env:TITLE="Tomcat $instanceName Instance"
$startup = ".\startup.bat"
Start-Process $startup $env:TITLE
                     } #end tomcatStartStop

############################################## end functions

############################################## Start drop down boxes

$DropDownBox = New-Object System.Windows.Forms.ComboBox
$DropDownBox.Location = New-Object System.Drawing.Size(20,50) 
$DropDownBox.Size = New-Object System.Drawing.Size(180,20) 
$DropDownBox.DropDownHeight = 200 
$Form.Controls.Add($DropDownBox) 

$wksList=@("Team 1", "Team 2", "Team 3", "Team 4")

foreach ($wks in $wksList) {
                      $DropDownBox.Items.Add($wks)
                              } #end foreach

############################################## end drop down boxes

############################################## Start text fields

$outputBox = New-Object System.Windows.Forms.TextBox 
$outputBox.Location = New-Object System.Drawing.Size(10,150) 
$outputBox.Size = New-Object System.Drawing.Size(565,200) 
$outputBox.MultiLine = $True 
$outputBox.ScrollBars = "Vertical" 
$Form.Controls.Add($outputBox) 

############################################## end text fields

############################################## Start button / Stop button

$Button = New-Object System.Windows.Forms.Button 
$Button.Location = New-Object System.Drawing.Size(250,30) 
$Button.Size = New-Object System.Drawing.Size(110,80) 
$Button.Text = "Start" 
$Button.Add_Click({tomcatStartStop("startup")}) 
$Form.Controls.Add($Button) 

$Button2 = New-Object System.Windows.Forms.Button 
$Button2.Location = New-Object System.Drawing.Size(350,30) 
$Button2.Size = New-Object System.Drawing.Size(110,80) 
$Button2.Text = "Stop" 
$Button2.Add_Click({tomcatStartStop("shutdown")}) 
$Form.Controls.Add($Button2) 

############################################## end buttons

$Form.Add_Shown({$Form.Activate()})
[void] $Form.ShowDialog()