New-UDPage -Url "/Create-Group" -Name "Create Group" -Content {
New-UDForm -Content {
    New-UDTextbox -Id "Name" -Label 'Name'
    New-UDSelect -Id 'Scope' -Label 'Scope' -Option {
        New-UDSelectOption -Name 'DomainLocal' -Value 'DomainLocal'
        New-UDSelectOption -Name 'Global' -Value 'Global'
        New-UDSelectOption -Name 'Universal' -Value 'Universal'
    } -DefaultValue 'DomainLocal'
} -OnValidate {
    if (-not $EventData.Name) {
        New-UDFormValidationResult -ValidationError "Name is required"
    } else {
        New-UDFormValidationResult -Valid
    }
} -OnSubmit {
    New-ADGroup -Name $EventData.Name -GroupScope $EventData.Scope 
    Show-UDToast "Group created sucessfully!" 
}
}