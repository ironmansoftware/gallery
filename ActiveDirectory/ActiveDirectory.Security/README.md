# Active Directory Security

This module contains resources for configuring PowerShell Universal authentication and authorization with Active Directory.

## About

This module looks up groups using `Get-ADGroup` in your current domain and creates roles using `New-PSURole` for each group in the domain. By default, all security groups will be returned. You can configure the filter by setting the `$PSUGroupFilter` variable.