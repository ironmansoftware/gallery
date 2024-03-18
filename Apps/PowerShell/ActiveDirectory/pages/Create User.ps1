New-UDPage -Url "/Create-User" -Name "Create User" -Content {
New-UDForm -Content {
    New-UDALert -Text "Enter the information below to create a user."
    New-UDTextbox -Id 'FirstName' -Label 'First Name'
    New-UDTextbox -Id 'LastName' -Label 'Last Name'
    New-UDTextbox -Id 'UserName' -Label 'Username'
    New-UDTextbox -Id 'Password' -Label 'Password' -Type password
} -OnValidate {
    if (-not $EventData.FirstName -or -not $EventData.LastName -or -not $EventData.UserName -or -not $EventData.Password) {
        New-UDFormValidationResult -ValidationError 'Required field is missing'
    }
    else {
        New-UDFormValidationResult -Valid
    }
} -OnSubmit {
    New-ADUser -Name $EventData.FirstName -GivenName $EventData.LastName -UserPrincipalName $EventData.UserName -AccountPassword (ConvertTo-SecureString -AsPlainText -String $EventData.Password)
    Show-UDToast "User created successfully!"
}
}