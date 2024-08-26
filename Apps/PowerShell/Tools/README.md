# PowerShell App Tools

A module for working with PowerShell Apps. 

## Commands

### `New-UDCenter`

Centers content in an App.

```powershell
New-UDCenter -Content {
    New-UDButton -Text 'Centered Button'
}
```

### `New-UDRight`

Right aligns content in an App.

```powershell
New-UDRight -Content {
    New-UDButton -Text 'Right Aligned Button'
}
```

### `New-UDConfirm`

Prompts the user to confirm an action.

```powershell
if(New-UDConfirm -Text "Do you want to delete this item?") {
    # Delete the item
}
```

### `New-UDLineBreak`

Adds a line break to the content.

```powershell
New-UDTypography -Text 'Line 1'
New-UDLineBreak
New-UDTypography -Text 'Line 2'
```

### `Show-UDEventData`

Displays the event data for a component.

```powershell
New-UDButton -Text 'Show Event Data' -OnClick {
    Show-UDEventData
}
```

### `Reset-UDPage`

Refreshes the current page.

```powershell
New-UDButton -Text 'Reset Page' -OnClick {
    Reset-UDPage
}
```

### `Show-UDObject`

Displays an object as JSON.


```powershell
$Object = @{
    Name = 'Adam'
    Age = 30
}

Show-UDObject -Object $Object
```

### `Get-UDCache`

Lists all items in `$Cache:` scope.
    
```powershell
$CacheItems = Get-UDCache
Show-UDObject -Object $InputObject
```

### `Show-UDVariable`

Displays a variable.

```powershell
$Variable = 'Hello'
Show-UDVariable -Name "Variable" 
```

### `Show-UDThemeColorViewer`

Displays the current theme colors.

```powershell
Show-UDThemeColorViewer
```

### `ConvertTo-UDJson`

Converts an object to JSON.

```powershell