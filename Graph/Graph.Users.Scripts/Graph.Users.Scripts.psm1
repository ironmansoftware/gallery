function New-Password {
    $chars = @(33..126) | ForEach-Object { [char]$_ }
    $passwordLength = 12
    $password = [String]::Empty
    for ($i = 0; $i -lt $passwordLength; $i++) {
        $password += $Chars | Get-Random
    }
    return $password
}

function New-PSUMgUser {
    <#
    .SYNOPSIS
    Creates a new user in Microsoft Graph with a generated password.
    
    .DESCRIPTION
    This function creates a new user in Microsoft Graph with a generated password. The function takes the user's display name, user principal name, and account enabled status as parameters. It generates a random password and sets the user's password profile accordingly. The function returns the user's display name, user principal name, generated password, and user ID.
    
    .PARAMETER DisplayName
    The display name of the user.
    
    .PARAMETER UserPrincipalName
    The user principal name (UPN) of the user.
    
    .PARAMETER AccountEnabled
    Specifies whether the user account is enabled.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$DisplayName,
        [Parameter(Mandatory = $true)]
        [string]$UserPrincipalName,
        [Parameter(Mandatory = $true)]
        [switch]$AccountEnabled
    )

    $PasswordProfile = @{
        Password = New-Password
    }

    Connect-MgGraph

    $MGUser = New-MgUser -DisplayName $DisplayName -UserPrincipalName $UserPrincipalName -PasswordProfile $PasswordProfile -AccountEnabled:$AccountEnabled

    @{
        DisplayName       = $DisplayName
        UserPrincipalName = $UserPrincipalName
        Password          = $password
        Id                = $MGUser.Id
    }

    Disconnect-MgGraph
}
