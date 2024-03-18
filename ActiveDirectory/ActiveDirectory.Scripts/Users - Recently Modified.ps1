function Get-UDUsersRecentlyModified {
    <#
    .SYNOPSIS
    Gets a list of users that were recently modified.
    
    .DESCRIPTION
    Gets a list of users that were recently modified.
    #>
    [System.ComponentModel.DisplayName("Users Recently Modified")]
    param()
    $prvDate = ((Get-Date).AddDays(-30)).Date
    Get-ADUser -Filter { whenChanged -ge $prvDate } -Properties whenChanged | Select Name, whenChanged | Sort-Object whenChanged
}