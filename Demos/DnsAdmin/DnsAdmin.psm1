function New-ADnsRecord {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidatePattern('^(srv|clt)\d{6}$')]
        [String]$Name,

        [Parameter(Mandatory)]
        [ValidatePattern('^192\.168\.56\.\d{1,3}$')]
        [String]$IP
    )

    $splat = @{
        ZoneName = 'igo.com'
        ComputerName = 'DC01.igo.com'
        Name = $Name
    }

    Write-Verbose -Message "Creating new DNS record with following parameters:"
    [PSCustomObject]$splat | Out-String -Stream | Write-Verbose

    try {
        $existing = Get-DnsServerResourceRecord @splat -ErrorAction Stop
    } catch {
        if ($_.Exception.Message -notlike "*Failed to get $Name record in igo.com zone on DC01.igo.com server.*") {
            Write-Warning -Message "Failed to get info about record $Name - $_"
        }
    }

    if ($existing) {
        $currentIP = $existing.RecordData.IPv4Address.IPAddressToString
        Write-Warning -Message "Record $Name already exists with IP $currentIP"
        if ($IP -ne $currentIP) {
            Write-Warning -Message "Not updating DNS record. Please delete old one first."
        }
    } else {
        try {
            Add-DnsServerResourceRecordA @splat -ErrorAction Stop -IPv4Address $IP
        } catch {
            throw "Some error handling goes here. Event log maybe? Caught $_"
        }
    }

}