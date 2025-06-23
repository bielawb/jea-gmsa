<# 
    We use it in 3 main scenarios:
    - utilities w/ impersonation
    - base for SCOM monitoring
    - base for PowerShell Universal APIs
#>
# Endpoint to talk to 3rd party API with shared token...
Enter-PSSession -ComputerName PSU -Credential $creds
Get-SkyNetData -Token mytoken -Verbose
Get-SkyNetData -Verbose
Import-Clixml -Path ~\SkyNetToken.clixml | % *Network* | % P*word
Exit-PSSession

Enter-PSSession -ComputerName PSU -Credential $creds -ConfigurationName SkyNet
Get-SkyNetData -Verbose
Get-Command
Exit-PSSession
$remote = New-PSSession -ComputerName PSU -Credential $creds -ConfigurationName SkyNet
$token = Get-Credential token
Invoke-Command -Session $remote -ScriptBlock { Export-Clixml -Path ~\SkyNetToken.clixml -InputObject $using:token -Verbose }
Invoke-Command -Session $remote -ScriptBlock { Get-SkyNetData -Verbose }
Invoke-Command -Session $remote -ScriptBlock { Import-Clixml -Path ~\SkyNetToken.clixml }

# SCOM runs as system, but what if we want to monitor something outside...?
# Scheduled tasks can run as other user...
Get-ChildItem -Path C:\Windows\Temp\*.json | Remove-Item -Force
Get-ScheduledTask -TaskName RunAsGMSA | ForEach-Object -MemberName Principal
Start-ScheduledTask -TaskName RunAsGMSA
Get-Content -Path C:\Windows\Temp\gmsa.json

Get-ScheduledTask -TaskName FakeSCOM | ForEach-Object -MemberName Principal
Start-ScheduledTask -TaskName FakeSCOM
Get-Content -Path C:\Windows\Temp\scom.json

# PSU
Start-Process -FilePath https://psu.igo.com/dns/Home