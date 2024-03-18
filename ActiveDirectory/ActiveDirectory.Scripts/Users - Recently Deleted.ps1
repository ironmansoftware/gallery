function Get-UDUsersRecentlyDeleted {
    <#
    .SYNOPSIS
    Gets a list of users that were recently deleted.
    
    .DESCRIPTION
    Gets a list of users that were recently deleted.
    #>
    [System.ComponentModel.DisplayName("Users Recently Deleted")]
    param()
    $prvDate = ((Get-Date).AddDays(-30)).Date
    Get-ADObject -IncludeDeletedObjects -Filter { objectClass -eq "user" -and IsDeleted -eq $True -and whenChanged -ge $prvDate } -Properties samaccountname, distinguishedname, whencreated, whenchanged | select -Property samaccountname, distinguishedname, whencreated, whenchanged
}