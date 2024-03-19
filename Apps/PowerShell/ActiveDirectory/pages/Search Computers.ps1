New-UDPage -Url "/Search-Computers" -Name "Search Computers" -Icon (New-UDIcon -Icon 'Search') -Content {
New-UDTypography -Text "Search for computers within AD. By default, standard PowerShell filter syntax is used (e.g. Name -like 'j*')."
  New-UDElement -Tag 'p'
  New-UDForm -Content {
    New-UDTextbox -Label 'Filter' -Id 'filter'
    New-UDCheckbox -Label 'Use LDAP filter' -Id 'ldapFilter'
  } -OnSubmit {
    if ($EventData.LdapFilter) {
      $Session:Objects = Get-ADComputer -LdapFilter $EventDat.filter 
    }
    else {
      $Session:Objects = Get-ADComputer -Filter $EventData.filter 
    }
      
    Sync-UDElement -Id 'adObjects'
  }
  
  New-UDDynamic -Id 'adObjects' -Content {
    if ($Session:Objects -eq $null) {
      return
    }
    New-UDTable -Title 'Objects' -Data $Session:Objects -Columns @(
      New-UDTableColumn -Property Name -Title "Name" -Filter
      New-UDTableColumn -Property DistinguishedName -Title "Distinguished Name" -Filter
      New-UDTableColumn -Property ViewObject -Title "View Object" -Render {
        $Guid = $EventData.ObjectGUID
        New-UDButton -Text 'View Object' -OnClick {
          Invoke-UDRedirect "/Object-Info/$Guid"
        }
      }
    ) -Filter
  }
}