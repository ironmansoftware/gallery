New-UDPage -Url "/group-membership" -Name "Group Membership" -Icon (New-UDIcon -Icon 'Users' -Style @{ marginRight = "10px" }) -Content {
    New-UDTypography -Text 'Select Group' -Variant h5

    New-UDAutocomplete -OnLoadOptions {
        Get-ADGroup -Filter "Name -like '*$body*'"  | Select-Object -ExpandProperty Name | ConvertTo-Json
    } -OnChange {
        $Session:SelectedGroup = $Body 
        Sync-UDElement -Id 'members'
    }

    New-UDElement -Tag 'div' -Attributes @{
        style = @{
            margin = '10px'
        }
    }

    New-UDDynamic -Id 'members' -Content {
        if ($Session:SelectedGroup) {
            $Data = Get-ADGroupMember -Identity $Session:SelectedGroup
            New-UDTable -Title $Session:SelectedGroup -Data $Data -ShowPagination -Columns @(
                New-UDTableColumn -Property Name -Title 'Name'
                New-UDTableColumn -Property Remove -Title Remove -Render {
                    $DN = $EventData.DistinguishedName
                    New-UDButton -Text 'Remove' -OnClick {
                        $ADUser = Get-ADGroupMember -Identity $Session:SelectedGroup | Where-Object { $_.DistinguishedName -eq $DN }
                        Remove-ADGroupMember -Identity $Session:SelectedGroup -Members $ADUser -Confirm:$false
                        Sync-UDElement -Id 'members'
                    }
                }
            )

            New-UDElement -Tag 'div' -Attributes @{
                style = @{
                    margin = '10px'
                }
            }

            New-UDTypography -Text "Add Members to $Session:SelectedGroup" -Variant h5
    
            New-UDAutocomplete -OnLoadOptions {
                Get-ADUser -Filter "Name -like '*$body*'"  | Select-Object -ExpandProperty DistinguishedName | ConvertTo-Json
            } -OnChange {
                $Session:SelectedUser = $Body 
            }
    
            New-UDButton -Text 'Add Member' -OnClick {
                if ($Session:SelectedUser) {
                    Add-ADGroupMember -Identity $Session:SelectedGroup -Members (Get-ADUser -Identity $Session:SelectedUser)
                    Show-UDToast -Message "Added $Session:SelectedUser to $Session:SelectedGroup"
                    Sync-UDElement -Id 'members'
                }
            }
        }
    }
}