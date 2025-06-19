<# 
    Regular PowerShell endpoint:
    - no control
    - double-hop
    - no delegation
#>

Enter-PSSession -ComputerName psu.igo.com -Credential $creds

# Some testing...
whoami
Get-ChildItem -Path \\dc01.igo.com\SYSVOL
Stop-Service -Name W3SVC
Start-Service -Name W3SVC

# Our own configurations....
Get-PSSessionConfiguration
Get-PSSessionConfiguration |
    Where-Object -Property Name -NotMatch microsoft -OutVariable ours

$ours[0].RoleDefinitions | Format-Custom
$ours[0].ConfigFilePath
$ours[0].SessionType


# Constrained, but w/o delegation
$ours.Where{ -not $_.RunAsUser }.Name
Exit-PSSession
Enter-PSSession -ComputerName psu.igo.com -Credential $creds -ConfigurationName DnsAdminJea

# Local works. Remote... not so much.
Get-Content -Path C:\Windows\system.ini
Add-DnsServerResourceRecordA -ComputerName dc01.igo.com -ZoneName igo.com -Name test -IPv4Address 1.2.3.4
ls
$variable = Get-Content -Path C:\Windows\system.ini -Raw
Exit-PSSession

# only WinRM. :(
Start-Process 'https://learn.microsoft.com/en-us/powershell/scripting/security/remoting/ssh-remoting-in-powershell?view=powershell-7.5'