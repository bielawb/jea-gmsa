configuration JeaDsc {
    Import-DscResource -ModuleName @{ ModuleName = 'JeaDsc'; RequiredVersion = '0.7.2' }
    Import-DscResource -ModuleName @{ ModuleName = 'ComputerManagementDSc'; RequiredVersion = '10.0.0' }
    
    node $AllNodes.NodeName {
        JeaRoleCapabilities DnsAdmin {
            Path = 'C:\Program Files\WindowsPowerShell\Modules\JeaRoles\RoleCapabilities\DnsAdmin.psrc'
            ModulesToImport = 'DnsServer'
            VisibleFunctions = 'Add-DnsServerResourceRecordA', 'Get-Content'
            VisibleProviders = 'FileSystem'
            Description = 'Role that allows creating A records'
        }

        JeaRoleCapabilities ApiEndpoint {
            Path = 'C:\Program Files\WindowsPowerShell\Modules\JeaRoles\RoleCapabilities\ApiEndpoint.psrc'
            ModulesToImport = 'SkyNet'
            VisibleFunctions = 'Get-SkyNetData'
            VisibleCmdlets = 'Export-CliXml'
            VisibleProviders = 'FileSystem'
            Description = 'Endpoint for made-up 3rd party API'
        }

        JeaRoleCapabilities DnsAdminModule {
            Path = 'C:\Program Files\WindowsPowerShell\Modules\JeaRoles\RoleCapabilities\DnsAdminModule.psrc'
            ModulesToImport = 'DnsAdmin', 'DnsServer'
            VisibleFunctions = 'New-ADnsRecord'
            Description = 'Role that allows creating A records with validation in igo.com domain'
        }

        JeaSessionConfiguration DnsAdmin {
            Name = 'DnsAdminJea'
            RoleDefinitions = @'
                @{
                    'IGO\DnsAdminsJea' = @{
                        RoleCapabilities = 'DnsAdmin'
                    }
                }
'@
            RunAsVirtualAccount = $true
        }

        JeaSessionConfiguration DnsAdminGmsa {
            Name = 'DnsAdminGmsa'
            RoleDefinitions = @'
                @{
                    'IGO\DnsAdminsJea' = @{
                        RoleCapabilities = 'DnsAdminModule'
                    }
                }
'@
            GroupManagedServiceAccount = 'IGO\svg_dns'
        }

        JeaSessionConfiguration ApiEndpoint {
            Name = 'SkyNet'
            RoleDefinitions = @'
                @{
                    'IGO\SkyNet' = @{
                        RoleCapabilities = 'ApiEndpoint'
                    }
                }
'@
            GroupManagedServiceAccount = 'IGO\svg_skynet'
        }

        ScheduledTask FakeScom {
            TaskName = 'FakeSCOM'
            ActionExecutable = 'C:\windows\system32\WindowsPowerShell\v1.0\powershell.exe'
            ActionArguments = '-ExecutionPolicy Bypass -File C:\windows\Temp\scom.ps1'
            ScheduleType = 'Once'
            Enable = $true
            RunLevel = 'Highest'
        }

        ScheduledTask RunAsGmsa {
            TaskName = 'RunAsGMSA'
            ActionExecutable = 'C:\windows\system32\WindowsPowerShell\v1.0\powershell.exe'
            ActionArguments = '-ExecutionPolicy Bypass -File c:\Windows\Temp\gmsa.ps1'
            ScheduleType = 'Once'
            Enable = $true
            ExecuteAsGMSA = 'IGO\svg_skynet$'
        }
    }
}

JeaDsc -ConfigurationData @{
    AllNodes = @(
        @{
            NodeName = 'PSU'
        }
    )
} -OutputPath C:\RecycleBin\DSC