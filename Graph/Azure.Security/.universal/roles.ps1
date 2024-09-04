if ($PSUAzureSecurityTenantId) {
    Connect-MgGraph -TenantId $PSUAzureSecurityTenantId -ClientSecretCredential $Secret:PSUAzureSecurityCredential -NoWelcome
    Get-MgGroup | ForEach-Object {
        New-PSURole -Name $_.DisplayName -ClaimType 'groups' -ClaimValue $_.Id -Description $_.Description
    }
}