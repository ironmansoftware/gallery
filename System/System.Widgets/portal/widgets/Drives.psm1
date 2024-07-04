$Variables["Drives"] = (Get-PSDrive -PSProvider FileSystem | ForEach-Object {
        [PSCustomObject]@{
            Name = $_.Name 
            Free = [Math]::Round($_.Free / 1GB, 2)
            Used = [Math]::Round($_.Used / 1GB, 2)
        }
    })