New-UDPage -Url "/Inactive-Users" -Name "Inactive Users" -Icon (New-UDIcon -Icon 'Stop' -Style @{ marginRight = "10px" }) -Content {
$When = ((Get-Date).AddDays(-30)).Date
$InactiveUsers = Get-ADUser -Filter {LastLogonDate -lt $When} -Properties * | select-object samaccountname,DistinguishedName,LastLogonDate
  $Columns = @(
    New-UDTableColumn -Property samaccountname -Title "Name" -Filter
    New-UDTableColumn -Property DistinguishedName -Title "Distinguished Name" -Filter
    New-UDTableColumn -Property LastLogonDate -Title "Last Logon Date" -Filter
  )
  New-UDTable -Data $InactiveUsers -Columns $Columns -ShowFilter
}