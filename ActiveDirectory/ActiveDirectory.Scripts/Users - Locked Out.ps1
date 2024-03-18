function Get-UDLockedOutUsers {
    <#
    .SYNOPSIS
    Gets a list of locked out users.
    
    .DESCRIPTION
    Gets a list of locked out users.
    #>
    [System.ComponentModel.DisplayName("Locked Out Users")]
    param()
    Search-AdAccount -LockedOut | Select-Object SamAccountName, DistinguishedName
}