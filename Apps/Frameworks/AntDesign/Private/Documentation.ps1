function Get-AntDesignHelpBlock {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$CommandName
    )

    $command = Get-Command -Name $CommandName -ErrorAction Stop
    $commandSourcePath = $command.ScriptBlock.Ast.Extent.File

    if ([string]::IsNullOrWhiteSpace($commandSourcePath)) {
        throw "Unable to locate source file for $CommandName."
    }

    if (-not $script:AntDesignModuleSourceByPath) {
        $script:AntDesignModuleSourceByPath = @{}
    }

    if (-not $script:AntDesignModuleSourceByPath.ContainsKey($commandSourcePath)) {
        $script:AntDesignModuleSourceByPath[$commandSourcePath] = Get-Content -Path $commandSourcePath -Raw
    }

    $pattern = "(?ms)function\s+$([regex]::Escape($CommandName))\s*\{\s*<#(?<help>.*?)#>"
    $match = [regex]::Match($script:AntDesignModuleSourceByPath[$commandSourcePath], $pattern)

    if (-not $match.Success) {
        throw "Unable to locate comment-based help for $CommandName."
    }

    $match.Groups['help'].Value
}

function ConvertFrom-AntDesignExampleBlock {
    [CmdletBinding()]
    param(
        [string[]]$Lines,
        [int]$Index
    )

    $content = [System.Collections.Generic.List[string]]::new()

    foreach ($line in $Lines) {
        $content.Add($line.TrimEnd())
    }

    while ($content.Count -gt 0 -and [string]::IsNullOrWhiteSpace($content[0])) {
        $content.RemoveAt(0)
    }

    while ($content.Count -gt 0 -and [string]::IsNullOrWhiteSpace($content[$content.Count - 1])) {
        $content.RemoveAt($content.Count - 1)
    }

    $title = "Example $Index"

    if ($content.Count -gt 0 -and $content[0] -match '^#\s*(.+)$') {
        $title = $Matches[1].Trim()
        $content.RemoveAt(0)
    }

    $splitIndex = -1

    for ($lineIndex = 0; $lineIndex -lt $content.Count; $lineIndex++) {
        if ([string]::IsNullOrWhiteSpace($content[$lineIndex])) {
            $splitIndex = $lineIndex
            break
        }
    }

    if ($splitIndex -ge 0) {
        $codeLines = @($content.GetRange(0, $splitIndex))
        $descriptionLines = @($content.GetRange($splitIndex + 1, $content.Count - $splitIndex - 1))
    }
    else {
        $codeLines = @($content)
        $descriptionLines = @()
    }

    [ordered]@{
        title       = $title
        code        = ($codeLines -join [Environment]::NewLine).Trim()
        description = ($descriptionLines -join ' ').Trim()
    }
}

function ConvertFrom-AntDesignHelpList {
    [CmdletBinding()]
    param(
        [string]$Text
    )

    if ([string]::IsNullOrWhiteSpace($Text)) {
        return @()
    }

    @(
        $Text -split "`r?`n" |
            ForEach-Object { $_.Trim() } |
            Where-Object { -not [string]::IsNullOrWhiteSpace($_) } |
            ForEach-Object { $_ -replace '^[\-\*\u2022]\s*', '' }
    )
}

function ConvertFrom-AntDesignHelpBlock {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$CommandName
    )

    $helpBlock = Get-AntDesignHelpBlock -CommandName $CommandName
    $lines = @($helpBlock -split "`r?`n" | ForEach-Object { $_.TrimEnd() })

    $result = [ordered]@{
        Synopsis    = ''
        Description = ''
        Notes       = ''
        Parameters  = @{}
        Examples    = @()
    }

    $currentSection = $null
    $currentName = $null
    $buffer = [System.Collections.Generic.List[string]]::new()

    function Save-AntDesignHelpSection {
        param(
            [string]$Section,
            [string]$Name,
            [System.Collections.Generic.List[string]]$SectionBuffer
        )

        if ([string]::IsNullOrWhiteSpace($Section)) {
            return
        }

        $value = ($SectionBuffer.ToArray() -join [Environment]::NewLine).Trim()

        if ([string]::IsNullOrWhiteSpace($value)) {
            return
        }

        switch ($Section) {
            'Synopsis' {
                $result['Synopsis'] = $value
            }
            'Description' {
                $result['Description'] = $value
            }
            'Notes' {
                $result['Notes'] = $value
            }
            'Parameter' {
                $result.Parameters[$Name] = ($SectionBuffer.ToArray() -join ' ').Trim()
            }
            'Example' {
                $result['Examples'] += ,(ConvertFrom-AntDesignExampleBlock -Lines $SectionBuffer.ToArray() -Index ($result['Examples'].Count + 1))
            }
        }
    }

    foreach ($line in ($lines + '.END')) {
        $trimmedLine = $line.TrimStart()

        if ($trimmedLine -match '^\.(\w+)(?:\s+(.+))?$') {
            Save-AntDesignHelpSection -Section $currentSection -Name $currentName -SectionBuffer $buffer
            $buffer.Clear()

            switch ($Matches[1].ToUpperInvariant()) {
                'SYNOPSIS' {
                    $currentSection = 'Synopsis'
                    $currentName = $null
                }
                'DESCRIPTION' {
                    $currentSection = 'Description'
                    $currentName = $null
                }
                'NOTES' {
                    $currentSection = 'Notes'
                    $currentName = $null
                }
                'PARAMETER' {
                    $currentSection = 'Parameter'
                    $currentName = $Matches[2]
                }
                'EXAMPLE' {
                    $currentSection = 'Example'
                    $currentName = $null
                }
                Default {
                    $currentSection = $null
                    $currentName = $null
                }
            }

            continue
        }

        $buffer.Add($trimmedLine)
    }

    $result
}

function Invoke-AntDesignDocumentationExample {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Code
    )

    if ([string]::IsNullOrWhiteSpace($Code)) {
        return $null
    }

    try {
        & ([scriptblock]::Create($Code))
    }
    catch {
        New-UDAntDesignText -Text "Example preview failed: $($_.Exception.Message)"
    }
}

function Get-AntDesignCommandParameters {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$CommandName,
        [hashtable]$HelpParameters = @{}
    )

    $commonParameters = @(
        'Verbose',
        'Debug',
        'ErrorAction',
        'WarningAction',
        'InformationAction',
        'ProgressAction',
        'ErrorVariable',
        'WarningVariable',
        'InformationVariable',
        'OutVariable',
        'OutBuffer',
        'PipelineVariable'
    )

    $command = Get-Command -Name $CommandName -ErrorAction Stop

    foreach ($parameter in $command.Parameters.Values) {
        if ($parameter.Name -in $commonParameters) {
            continue
        }

        $parameterAttribute = $parameter.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] } | Select-Object -First 1
        $validateSetAttribute = $parameter.Attributes | Where-Object { $_ -is [System.Management.Automation.ValidateSetAttribute] } | Select-Object -First 1

        [ordered]@{
            name        = $parameter.Name
            type        = $parameter.ParameterType.Name
            required    = [bool]($null -ne $parameterAttribute -and $parameterAttribute.Mandatory)
            description = $HelpParameters[$parameter.Name]
            validValues = if ($null -ne $validateSetAttribute) { @($validateSetAttribute.ValidValues) } else { @() }
        }
    }
}

function Get-AntDesignComponentDocumentation {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Key,
        [Parameter(Mandatory)]
        [string]$Title,
        [Parameter(Mandatory)]
        [string]$CommandName,
        [string]$Category = 'General',
        [string]$SourceUrl
    )

    $help = ConvertFrom-AntDesignHelpBlock -CommandName $CommandName
    $examples = foreach ($example in $help.Examples) {
        [ordered]@{
            title       = $example.title
            description = $example.description
            code        = $example.code
            preview     = Invoke-AntDesignDocumentationExample -Code $example.code
        }
    }

    [ordered]@{
        key         = $Key
        title       = $Title
        category    = $Category
        commandName = $CommandName
        summary     = $help.Synopsis
        description = $help.Description
        whenToUse   = @(ConvertFrom-AntDesignHelpList -Text $help.Notes)
        sourceUrl   = $SourceUrl
        parameters  = @(Get-AntDesignCommandParameters -CommandName $CommandName -HelpParameters $help.Parameters)
        examples    = @($examples)
    }
}