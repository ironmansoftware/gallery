class ADQuery {
    [string]$Query = '(&(objectClass=user)(objectCategory=user))'
}

$Variables["Model"] = [ADQuery]::new()
$Variables["Results"] = @()
$Variables["ObjectCount"] = 0

function OnSearch {
    param($EventArgs)

    $Variables["Results"] = Get-ADObject -LDAPFilter $EventArgs.Model.Query
    $Variables["ObjectCount"] = $Variables["Results"].Count
}