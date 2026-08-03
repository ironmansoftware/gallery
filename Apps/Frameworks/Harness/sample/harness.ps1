function Get-AntDesignHarnessEntryPoint {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$DistPath,

        [Parameter(Mandatory)]
        [string]$BasePath
    )

    $manifestPath = Join-Path -Path $DistPath -ChildPath 'manifest.json'

    if (-not (Test-Path -Path $manifestPath)) {
        throw "Ant Design framework manifest not found at '$manifestPath'. Run npm run build in Apps/Frameworks/AntDesign first."
    }

    $manifest = Get-Content -Path $manifestPath -Raw | ConvertFrom-Json -AsHashtable
    $entry = $manifest['index.html']

    if (-not $entry) {
        throw "Ant Design framework manifest entry for 'index.html' was not found in '$manifestPath'."
    }

    $styles = @()

    if ($entry.ContainsKey('css') -and $entry.css.Count -gt 0) {
        $styles = @("$BasePath/$($entry.css[0] -replace '\\', '/')")
    }

    @{
        Scripts = @("$BasePath/$($entry.file -replace '\\', '/')")
        Styles = $styles
    }
}

$antDesignDistPath = Join-Path $HarnessScriptRoot '..\..\AntDesign\dist'
$antDesignAssetBasePath = '/frameworks/ant-design'
$antDesignEntryPoint = Get-AntDesignHarnessEntryPoint -DistPath $antDesignDistPath -BasePath $antDesignAssetBasePath

@{
    DashboardScript = Join-Path $HarnessScriptRoot 'dashboard.ps1'
    EndpointRoot = Join-Path $HarnessScriptRoot 'endpoints'
    StaticAssets = @(
        @{
            RequestPath = $antDesignAssetBasePath
            Path = $antDesignDistPath
        }
    )
    Shell = @{
        Title = 'PSU Framework Harness'
        MountId = 'root'
        Scripts = $antDesignEntryPoint.Scripts
        Styles = $antDesignEntryPoint.Styles
    }
}
