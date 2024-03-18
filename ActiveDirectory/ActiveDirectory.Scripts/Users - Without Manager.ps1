function Get-UDUsersWithoutManager {
    <#
    .SYNOPSIS
    Gets a list of users that do not have a manager.
    
    .DESCRIPTION
    Gets a list of users that do not have a manager.
    #>
    [System.ComponentModel.DisplayName("Users Without Manager")]
    param()
    Get-ADUser -LDAPFilter "(!manager=*)" -Properties DisplayName, UserPrincipalName, DistinguishedName | ForEach-Object {
        [PSCustomObject]@{
            DisplayName       = $_.DisplayName
            UserPrincipalName = $_.UserPrincipalName
            DistinguishedName = $_.DistinguishedName
        }
    }
}
