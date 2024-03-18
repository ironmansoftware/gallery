function Get-UDUsersNeverLoggedOn {
    <#
    .SYNOPSIS
    Gets a list of users that have never logged on.
    
    .DESCRIPTION
    Gets a list of users that have never logged on.
    #>
    [System.ComponentModel.DisplayName("Users Never Logged On")]
    param()
    Get-ADUser -Filter { -not (lastlogontime -like '*') } -Properties Name, SID, whenCreated | ForEach-Object {
        [PSCustomObject]@{
            Name        = $_.Name 
            SID         = $_.SID
            WhenCreated = $_.whenCreated
        }
    }
}