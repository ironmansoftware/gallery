function New-UDRandomPassword {
    param(
        [int]$Length = 12,
        [switch]$IncludeUppercase,
        [switch]$IncludeLowercase,
        [switch]$IncludeNumbers,
        [switch]$IncludeSpecialCharacters
    )

    $Characters = @()
    if ($IncludeUppercase) {
        $Characters += 65..90 | ForEach-Object { [char]$_ }
    }
    if ($IncludeLowercase) {
        $Characters += 97..122 | ForEach-Object { [char]$_ }
    }
    if ($IncludeNumbers) {
        $Characters += 48..57 | ForEach-Object { [char]$_ }
    }
    if ($IncludeSpecialCharacters) {
        $Characters += 33..47 | ForEach-Object { [char]$_ }
        $Characters += 58..64 | ForEach-Object { [char]$_ }
        $Characters += 91..96 | ForEach-Object { [char]$_ }
        $Characters += 123..126 | ForEach-Object { [char]$_ }
    }

    $Password = ""
    for ($i = 0; $i -lt $Length; $i++) {
        $Password += $Characters | Get-Random
    }

    $Password
}

function New-UDRandomPowerballNumbers {
    $Numbers = 1..69 | Get-Random -Count 5
    $Powerball = 1..26 | Get-Random
    $Numbers + $Powerball
}

function New-UDRandom {
    param(
        [Parameter()]
        [string[]]$Tools = @("Password", "GUID", "Number", "ListItem", "Powerball")
    )

    New-UDForm -Content {
        if ($Tools.Length -gt 1) {
            New-UDSelect -Label "Tool" -Option {
                $Tools | ForEach-Object {
                    New-UDSelectOption -Name $_ -Value $_ -Id -OnChange {
                        $Page:Tool = $EventData
                    }
                }
            }
        }
        else {
            $Page:Tool = $Tools[0]
        }

        if ($Page:Tool -eq "Password") {
            New-UDSlider -Label "Length" -Id "Length" -DefaultValue 12 -Min 4 -Max 128
            New-UDCheckbox -Label "Include Uppercase" -Id "IncludeUppercase"
            New-UDCheckbox -Label "Include Lowercase" -Id "IncludeLowercase"
            New-UDCheckbox -Label "Include Numbers" -Id "IncludeNumbers"
            New-UDCheckbox -Label "Include Special Characters" -Id "IncludeSpecialCharacters"
        }
        elseif ($Page:Tool -eq "Number") {
            New-UDSlider -Label "Minimum" -Id "Minimum" -DefaultValue 0 -Min 0 -Max 10000
            New-UDSlider -Label "Maximum" -Id "Maximum" -DefaultValue 100 -Min 0 -Max 10000
        }
        elseif ($Page:Tool -eq "ListItem") {
            New-UDTextarea -Label "Items" -Id "Items"
        }

    } -OnSubmit {
        if ($Page:Tool -eq "Password") {
            $Page:Password = New-UDRandomPassword -Length $EventData.Length -IncludeUppercase:$EventData.IncludeUppercase -IncludeLowercaseL$EventData.IncludeLowercase -IncludeNumbers $EventData.IncludeNumbers -IncludeSpecialCharacters $EventData.IncludeSpecialCharacters
        } 
        elseif ($Page:Tool -eq "GUID") {
            $Page:Guid = New-Guid
        }
        elseif ($Page:Tool -eq "Number") {
            $Page:Number = Get-Random -Minimum $EventData.Minimum -Maximum $EventData.Maximum
        }
        elseif ($Page:Tool -eq "ListItem") {
            $Page:Items = $EventData.Items -split "`n"
            $Page:Item = $Page:Items | Get-Random
        }
        elseif ($Page:Tool -eq "Powerball") {
            $Page:Powerball = New-UDRandomPowerballNumbers
        }
        Sync-UDElement -Id "Output"
    }

    New-UDDynamic -Id "Output" -Content {
        New-UDCard -Title 'Output' -Content {
            if ($Page:Tool -eq "Password") {
                New-UDTypography -Text $Page:Password
            }
            elseif ($Page:Tool -eq "GUID") {
                New-UDTypography -Text $Page:Guid
            }
            elseif ($Page:Tool -eq "Number") {
                New-UDTypography -Text $Page:Number
            }
            elseif ($Page:Tool -eq "ListItem") {
                New-UDTypography -Text $Page:Item
            }
            elseif ($Page:Tool -eq "Powerball") {
                $Page:Powerball | Select-Object -First 5 | ForEach-Object {
                    New-UDBadge -Text $_
                }
                New-UDBadge -Text $Page:Powerball[-1] -BackgroundColor "red"
            }
        }
    }
}