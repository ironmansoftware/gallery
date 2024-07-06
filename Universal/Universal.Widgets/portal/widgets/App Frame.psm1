function Initialize-PSUWidget {
    param(
        $AppName = "PowerShell Universal Documentation"
    )

    $App = Get-PSUApp -Name $AppName

    if ($App -eq $null) {
        $AppUrl = "/notfound"
    }
    else {
        $AppUrl = $App.BaseUrl
    }

    $Variables["App"] = $AppUrl
}