class LocalUserForm {
    [string]$UserName
    [string]$Password
    [string]$ConfirmPassword
}

$Variables["Model"] = [LocalUserForm]::new()

function Submit {
    param($EventArgs)

    if ($EventArgs.Model.Password -ne $EventArgs.Model.ConfirmPassword) {
        $Message.Error("Passwords do not match")    
        return
    }

    $Message.Info("Creating user...")
    $Variables["Disabled"] = $true

    try {
        Invoke-PSUScript -Name "Microsoft.PowerShell.LocalAccounts\New-LocalUser" -Parameters @{
            Name     = $EventArgs.Model.UserName
            Password = $EventArgs.Model.Password
        } -Wait -ErrorAction Stop
    }
    catch {
        $Message.Error($_.ToString())
        return
    }
    finally {
        $Variables["Disabled"] = $false
    }

    $Message.Success("User was created!")
    
}