New-UDPage -Url "/Domain-Controllers" -Name "Domain Controllers" -Icon (New-UDIcon -Icon 'Server') -Content {
$DomainControllers = Get-ADDomainController
New-UDTable -Data  $DomainControllers -ShowFilter -Columns @(
    New-UDTableColumn -Property 'HostName' -Title 'Host Name'
    New-UDTableColumn -Property 'IPv4Address' -Title 'IPv4 Address'
    New-UDTableColumn -Property 'Domain' -Title 'Domain'
    New-UDTableColumn -Property 'OperatingSystem' -Title 'Operating System'
)
}