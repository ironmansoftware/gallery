New-UDPage -Url "/Reset-Password" -Name "Reset Password"  -Icon (New-UDIcon -Icon 'Lock' -Style @{ marginRight = "10px" }) -Content {
  New-UDForm -Content {
    New-UDTextbox -Id 'txtIdentity' -Label 'User Name' 
    New-UDTextbox -Id 'txtPassword' -Label 'Password' -Type password 
    New-UDCheckbox -Id 'chkUnlock' -Label 'Unlock'
    New-UDCheckbox -Id 'chkChangePasswordOnLogon' -Label 'Change password on logon' 
  } -OnSubmit {
    $SecurePassword = ConvertTo-SecureString $EventData.txtPassword -AsPlainText -Force
      
    Set-ADAccountPassword -Identity $EventData.txtIdentity -NewPassword $SecurePassword -Reset
      
    if ($EventData.chkUnlock) {
      Unlock-ADAccount –Identity $EventData.txtIdentity
    }
      
    if ($EventData.chkChangePasswordOnLogon) {
      Set-ADUser –Identity $EventData.txtIdentity -ChangePasswordAtLogon $true
    }
  }
}