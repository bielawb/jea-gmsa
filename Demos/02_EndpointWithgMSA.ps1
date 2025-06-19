<# 
    gMSA - Group Managed Service Account... 101
#>

Get-ADServiceAccount -Identity svg_task -Properties 'msDS-ManagedPassword', PrincipalsAllowedToRetrieveManagedPassword -OutVariable gmsa

$gmsa.PrincipalsAllowedToRetrieveManagedPassword

(ConvertFrom-ADManagedPasswordBlob -Blob $gmsa.'msDS-ManagedPassword').CurrentPassword


# No constrains, we can do whatever we want!
Enter-PSSession -ComputerName psu.igo.com -Credential $creds -ConfigurationName Raw

whoami.exe
$variable = Get-ChildItem C:\Windows\system32 -File
$variable[0].FullName | Remove-Item -WhatIf

# 2nd hop is no longer an issue
Get-ChildItem -Path \\dc01.igo.com\SYSVOL
Get-DnsServer -ComputerName dc01.igo.com

# Lets combine both...

Enter-PSSession -ComputerName psu.igo.com -Credential $creds -ConfigurationName DnsAdminGmsa

Add-DnsServerResourceRecordA -ComputerName dc01.igo.com -ZoneName igo.com -Name test -IPv4Address 1.2.3.4
Get-Command
Get-Command -Syntax -Name New-ADnsRecord

Exit-PSSession
$session = New-PSSession -ComputerName psu.igo.com -Credential $creds -ConfigurationName DnsAdminGmsa
Import-PSSession -Session $session -CommandName New-ADnsRecord
Get-Command -Syntax -Name New-ADnsRecord
New-ADnsRecord -Name test01 -IP 192.168.56.212
New-ADnsRecord -Name srv123456 -IP 192.168.56.212
