$creds = Import-Clixml -Path C:\RecycleBin\creds.clixml
# $session = New-PSSession -ComputerName 192.168.56.10 -Credential $creds
$sampleFolder = Join-Path $PSScriptRoot -ChildPath SampleFiles
if ($env:PSModulePath -split ';' -notcontains $sampleFolder) {
    $env:PSModulePath += ";$sampleFolder"
}

$3 = @($psISE.CurrentPowerShellTab.Files.Where{ $_.DisplayName -eq '3.xaml' })[0]
$2 = @($psISE.CurrentPowerShellTab.Files.Where{ $_.DisplayName -eq '2.xaml' })[0]
$1 = @($psISE.CurrentPowerShellTab.Files.Where{ $_.DisplayName -eq '1.xaml' })[0]
$0 = @($psISE.CurrentPowerShellTab.Files.Where{ $_.DisplayName -eq '0.ps1' })[0]
$main = @($psISE.CurrentPowerShellTab.Files.Where{ $_.DisplayName -eq '00_Title.xaml' })[0]

Start-Sleep -Milliseconds 100
$wshell.SendKeys('^r')
do {
    Start-Sleep -Seconds 10
} while ((Get-Date).Hour -lt 9)

# 3... 2... 1... countdown - PS ISE style. :P
foreach ($file in $0, $3, $2, $1) {
    Start-Sleep -Seconds 1
    $null = $psISE.CurrentPowerShellTab.Files.Remove($file)
}
$psISE.CurrentPowerShellTab.Files.SetSelectedFile($main)