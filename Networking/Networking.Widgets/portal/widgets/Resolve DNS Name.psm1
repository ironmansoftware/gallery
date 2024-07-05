$Variables["Resolved"] = ""

class ResolveDns {
    [string]$HostName 
}

$Variables["Model"] = [ResolveDns]::new()

function ResolveDns {
    param($EventArgs)

    $Variables["Resolved"] = Resolve-DnsName $EventArgs.Model.HostName | Out-String

}