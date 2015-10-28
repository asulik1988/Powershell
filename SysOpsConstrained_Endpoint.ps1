cd C:\RTS\Scripts\Repair-Crystal
Write-host "You are logged into $env:computername. Please run the following command to get started ' Repair-Crystal '"
#Define any visible cmdlets that we want visible to the user

[string[]]$PublicCmdlets = 'Get-Process','Get-Service','Clear-Host','Get-Alias','Get-Location','Select-Object'

#Define applications that I want visible to the user; ie: ping, netstat, etc...

[string[]]$Apps = 'ping','tracert','ipconfig'

[string[]]$PublicApps = ForEach ($app in $apps) {

    Get-Command $app | Select -ExpandProperty Definition

}
#Define any Public Aliases

[string[]]$PublicAliases = 'gsv','gps','ps','exsn','cls','gal','pwd'

#Define Public Scripts

[string[]]$PublicScripts = 'C:\RTS\Scripts\Repair-Crystal\Repair-Crystal.ps1'

#Cmdlets

Get-Command | ForEach {

    If ($PublicCmdlets -notcontains $_.Name) {

        $_.Visibility = 'Private'

    }

}

#Aliases

Get-Alias | ForEach {

    If ($PublicAliases -notcontains $_.Name) {

        $_.Visibility = 'Private'

    }

}

#Variables

Get-Variable | ForEach {

    $_.Visibility = 'Private'

}

$ExecutionContext.SessionState.Applications.Clear()

$ExecutionContext.SessionState.Scripts.Clear()

If ($PublicApps) {

    $ExecutionContext.SessionState.Applications.AddRange(`

    ($PublicApps -as [System.Collections.Generic.IEnumerable[string]]))

}

If ($PublicScripts) {

    $ExecutionContext.SessionState.Scripts.AddRange(`

    ($PublicScripts -as [System.Collections.Generic.IEnumerable[string]]))

}

$ExecutionContext.SessionState.LanguageMode = "FullLanguage"

$SessionStateType = [System.Management.Automation.Runspaces.InitialSessionState]

$SessionState = $SessionStateType::CreateRestricted("RemoteServer")

$proxyfunctions = $SessionState.Commands | Where {

    $_.CommandType -eq 'Function'

}

$proxyfunctions | ForEach {

    Set-Item "Function:\$($_.Name)" $_.Definition

}