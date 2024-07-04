
$Variables["Processes"] = (Get-Process | ForEach-Object {
        [PSCustomObject]@{
            Id   = $_.Id
            Name = $_.Name 
            VM   = [Math]::Round($_.VM / 1KB, 2)
            NPM  = [Math]::Round($_.NPM / 1KB, 2)
            PM   = [Math]::Round($_.PM / 1KB, 2)
        }
    })