function Get-UDUsersRecentlyCreated {
    <#
    .SYNOPSIS
    Gets a list of users that were recently created.
    
    .DESCRIPTION
    Gets a list of users that were recently created.
    #>
    [System.ComponentModel.DisplayName("Users Recently Created")]
    param()
    $prvDate = ((Get-Date).AddDays(-30)).Date
    Get-ADUser -Filter { whenCreated -ge $prvDate } -Properties whenCreated | Select Name, whenCreated | Sort-Object whenCreated
    
}
