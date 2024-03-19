New-UDPage -Url "/Object-Info/:guid" -Name "Object Info"  -Icon (New-UDIcon -Icon 'User' -Style @{ marginRight = "10px" }) -Content {
  $Object = Get-ADObject -IncludeDeletedObjects:$EventData.includeDeleted -Identity $Guid -Properties *
  New-UDTable -Data $Object.PSObject.Properties -Columns @(
    New-UDTableColumn -Property Name -Title "Name" -Filter
    New-UDTableColumn -Property Value -Title "Value" -Filter -Render { if ($EventData.Value) { $EventData.Value.ToString() } else { "" } }
  ) -Filter -Paging
}