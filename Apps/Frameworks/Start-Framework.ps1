[CmdletBinding()]
param(
    [Parameter(Mandatory, Position = 0)]
    [string]$Framework,

    [switch]$Build,

    [int]$Port = 5057,

    [switch]$NoBrowser,

    [switch]$PassThru
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Resolve-FrameworkDirectory {
    param(
        [Parameter(Mandatory)]
        [string]$FrameworkPath,

        [Parameter(Mandatory)]
        [string]$RootPath
    )

    $resolved = $null

    try {
        $resolved = Resolve-Path -LiteralPath $FrameworkPath -ErrorAction Stop
    }
    catch {
        $combinedPath = Join-Path $RootPath $FrameworkPath
        $resolved = Resolve-Path -LiteralPath $combinedPath -ErrorAction Stop
    }

    $frameworkDirectory = $resolved.ProviderPath
    if (-not (Test-Path -LiteralPath $frameworkDirectory -PathType Container)) {
        throw "Framework path must resolve to a directory: $FrameworkPath"
    }

    return $frameworkDirectory
}

function Invoke-FrameworkBuild {
    param(
        [Parameter(Mandatory)]
        [string]$FrameworkDirectory
    )

    $packageJson = Join-Path $FrameworkDirectory 'package.json'
    if (Test-Path -LiteralPath $packageJson) {
        Write-Host "Building framework with npm run build in $FrameworkDirectory"
        Push-Location $FrameworkDirectory
        try {
            & npm run build
            if ($LASTEXITCODE -ne 0) {
                throw "npm run build failed for $FrameworkDirectory"
            }
        }
        finally {
            Pop-Location
        }

        return
    }

    $buildScript = Join-Path $FrameworkDirectory 'build.ps1'
    if (Test-Path -LiteralPath $buildScript) {
        Write-Host "Building framework with $buildScript"
        & $buildScript
        return
    }

    $project = Get-ChildItem -LiteralPath $FrameworkDirectory -Filter *.csproj -File | Select-Object -First 1
    if ($null -ne $project) {
        Write-Host "Building framework with dotnet build $($project.FullName)"
        & dotnet build $project.FullName
        if ($LASTEXITCODE -ne 0) {
            throw "dotnet build failed for $($project.FullName)"
        }

        return
    }

    throw "No supported build surface was found in $FrameworkDirectory. Expected package.json, build.ps1, or a .csproj."
}

$frameworkRoot = Split-Path -Parent $PSCommandPath
$frameworkDirectory = Resolve-FrameworkDirectory -FrameworkPath $Framework -RootPath $frameworkRoot
$frameworkName = Split-Path -Leaf $frameworkDirectory
$definitionPath = Join-Path $frameworkDirectory 'harness.ps1'

if (-not (Test-Path -LiteralPath $definitionPath -PathType Leaf)) {
    throw "Framework harness definition was not found: $definitionPath"
}

if ($Build) {
    Invoke-FrameworkBuild -FrameworkDirectory $frameworkDirectory
}

$harnessProject = Join-Path $frameworkRoot 'Harness\src\PowerShellUniversal.Frameworks.Harness\PowerShellUniversal.Frameworks.Harness.csproj'
if (-not (Test-Path -LiteralPath $harnessProject -PathType Leaf)) {
    throw "Harness project was not found: $harnessProject"
}

$url = "http://127.0.0.1:$Port"
$dotnetArguments = @(
    'run'
    '--project'
    $harnessProject
    '--urls'
    $url
    '--'
    "--Harness:DefinitionPath=$definitionPath"
)

Write-Host "Starting $frameworkName on $url"
$process = Start-Process -FilePath 'dotnet' -ArgumentList $dotnetArguments -WorkingDirectory $frameworkRoot -PassThru

$deadline = (Get-Date).AddSeconds(30)
$isReady = $false
while ((Get-Date) -lt $deadline) {
    if ($process.HasExited) {
        throw "$frameworkName harness process exited before the server became ready. Exit code: $($process.ExitCode)"
    }

    try {
        $response = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 2
        if ($response.StatusCode -ge 200 -and $response.StatusCode -lt 500) {
            $isReady = $true
            break
        }
    }
    catch {
    }

    Start-Sleep -Milliseconds 250
}

if (-not $isReady) {
    if (-not $process.HasExited) {
        Stop-Process -Id $process.Id -Force
    }

    throw "$frameworkName harness did not become ready within 30 seconds on $url"
}

if (-not $NoBrowser) {
    Start-Process $url | Out-Null
}

if ($PassThru) {
    $process
}