function New-PSULocalAccount {
    <#
    .SYNOPSIS
    Creates a new local user account.
    
    .DESCRIPTION
    This function creates a new local user account on the local computer.
    
    .PARAMETER Name
    The name of the new user account.
    
    .PARAMETER Password
    The password for the new user account.
    
    .PARAMETER ConfirmPassword
    The password for the new user account, confirmed.
    
    .EXAMPLE
    $Password = ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force
    New-PSULocalAccount -Name "User1" -Password $Password -ConfirmPassword $Password
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,
        [Parameter(Mandatory = $true)]
        [securestring]$Password,
        [Parameter(Mandatory = $true)]
        [securestring]$ConfirmPassword
    )

    $PW = ConvertFrom-SecureString -SecureString $Password 
    $CPW = ConvertFrom-SecureString -SecureString $ConfirmPassword

    if ($PW -ne $CPW) {
        throw "Passwords do not match."
    }

    New-LocalUser -Name $Name -Password $Password 
}