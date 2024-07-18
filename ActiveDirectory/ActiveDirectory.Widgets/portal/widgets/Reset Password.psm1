class UserResetForm {
    [string]$UserName
    [string]$Password
    [string]$ConfirmPassword
}

$Variables["Model"] = [UserResetForm]::new()

function Submit {
    param($EventArgs)

    if ($EventArgs.Model.Password -ne $EventArgs.Model.ConfirmPassword) {
        $Message.Error("Passwords do not match")    
        return
    }

    $Variables["Disabled"] = $true

    try {
        Set-ADAccountPassword -Identity $EventArgs.Model.UserName -NewPassword (ConvertTo-SecureString -AsPlainText $EventArgs.Model.Password -Force) -Reset
    }
    catch {
        $Message.Error($_.ToString())
        return
    }
    finally {
        $Variables["Disabled"] = $false
    }

    $Message.Success("Password reset!")
    
}