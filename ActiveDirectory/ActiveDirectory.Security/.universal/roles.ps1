$Filter = 'GroupCategory -eq "Security"'
if ($PSUGroupFilter) {
    $Filter = $PSUGroupFilter
}

Get-ADGroup -Filter $Filter | ForEach-Object {
    New-PSURole -Name $_.Name -ClaimType 'http://schemas.microsoft.com/ws/2008/06/identity/claims/groupsid' -ClaimValue $_.SID.Value
}