function Get-PSUAntDesignFrameworkAssetBasePath {
    [CmdletBinding()]
    [OutputType([string])]
    param()

    '/frameworks/ant-design'
}

function Get-PSUAntDesignFrameworkManifestPath {
    [CmdletBinding()]
    [OutputType([string])]
    param()

    $moduleRoot = Split-Path -Path $PSScriptRoot -Parent
    Join-Path -Path $moduleRoot -ChildPath 'dist\manifest.json'
}

function Get-PSUAntDesignFrameworkManifestEntry {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param()

    $manifestPath = Get-PSUAntDesignFrameworkManifestPath

    if (-not (Test-Path -Path $manifestPath)) {
        throw "Ant Design framework manifest not found at '$manifestPath'. Run the frontend build first."
    }

    $manifest = Get-Content -Path $manifestPath -Raw | ConvertFrom-Json -AsHashtable
    $entry = $manifest['index.html']

    if (-not $entry) {
        throw "Ant Design framework manifest entry for 'index.html' was not found in '$manifestPath'."
    }

    $entry
}

function Get-PSUAntDesignFrameworkEntryPoint {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param()

    $basePath = Get-PSUAntDesignFrameworkAssetBasePath
    $entry = Get-PSUAntDesignFrameworkManifestEntry
    $scriptPath = $entry.file -replace '\\', '/'
    $stylesheetPath = $null

    if ($entry.ContainsKey('css') -and $entry.css.Count -gt 0) {
        $stylesheetPath = $entry.css[0] -replace '\\', '/'
    }

    [pscustomobject]@{
        BasePath       = $basePath
        ScriptPath     = "$basePath/$scriptPath"
        StylesheetPath = if ($stylesheetPath) { "$basePath/$stylesheetPath" } else { $null }
    }
}