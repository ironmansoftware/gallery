[CmdletBinding(DefaultParameterSetName = 'Empty')]
param(
    # Version to install. Use 'latest' for the current release, or specify
    # a version string such as '2025.3.1.0'.
    [Parameter(HelpMessage = "PSU version to install, e.g. '2025.3.1.0'. Use 'latest' for the current release.")]
    [string]$PSUVersion    = "latest",

    [Parameter(HelpMessage = "Optional short identifier for this sandbox. A random 6-character ID is generated when omitted.")]
    [string]$SandboxId     = "",

    [Parameter(HelpMessage = "Stop all processes and permanently delete the sandbox directory.")]
    [switch]$Teardown,

    [Parameter(HelpMessage = "List all existing sandboxes found in the temp directory.")]
    [switch]$List,

    [Parameter(ParameterSetName = 'Empty', HelpMessage = "Start with an empty PSU repository, no configuration seeded.")]
    [switch]$Empty,

    [Parameter(ParameterSetName = 'FromDirectory', HelpMessage = "Path to a directory whose contents will be copied into the PSU repository folder before the server starts.")]
    [string]$ConfigurationDirectory,

    [Parameter(ParameterSetName = "FromGit")]
    [Switch]$Git,

    [Parameter(ParameterSetName = 'FromGit', HelpMessage = "Git repository URL to clone into the PSU repository folder before the server starts.")]
    [string]$GitRepo = "https://github.com/Devolutions/powershell-universal-demo",

    [Parameter(HelpMessage = "Optional list of PSU features/plugins to enable. Supported values: 'MCP', 'C#', 'YARP'.")]
    [string[]]$Features,

    [Parameter(HelpMessage = "Database backend to use. Defaults to 'SQLite'. Other options: 'SQL' (SQL Server) or 'PostgreSQL'.")]
    [ValidateSet("SQLite", "SQL", "PostgreSQL")]
    [string]$DatabaseType = "SQLite",

    [Parameter(HelpMessage = "Connection string for the selected database. When omitted with SQLite, defaults to a file in the sandbox data directory.")]
    [string]$DatabaseConnectionString
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ---------------------------------------------------------------------------
# Helper: pretty summary box
# ---------------------------------------------------------------------------
function Write-Box {
    param([string[]]$Lines, [ConsoleColor]$BorderColor = 'Green')
    $width  = ($Lines | Measure-Object -Property Length -Maximum).Maximum + 4
    $border = '=' * $width
    Write-Host $border -ForegroundColor $BorderColor
    foreach ($l in $Lines) { Write-Host "  $l" -ForegroundColor White }
    Write-Host $border -ForegroundColor $BorderColor
}

# ---------------------------------------------------------------------------
# Fetch productinfo (latest version + fallback for listing)
# ---------------------------------------------------------------------------
Write-Host "Fetching PSU release info..." -ForegroundColor Cyan
$ProductInfo   = Invoke-RestMethod https://devolutions.net/productinfo.json
$LatestVersion = $ProductInfo.PowerShellUniversal.Current.Version

# ---------------------------------------------------------------------------
# Resolve version label
# ---------------------------------------------------------------------------
if ($PSUVersion -eq "latest") {
    $Version = $LatestVersion
    Write-Host "Latest version  : $Version" -ForegroundColor Cyan
} else {
    $Version = $PSUVersion
    Write-Host "Target version  : $Version" -ForegroundColor Cyan
}

# ---------------------------------------------------------------------------
# -List: show all existing sandboxes
# ---------------------------------------------------------------------------
if ($List) {
    $sandboxDirs = Get-ChildItem -Path $env:TEMP -Directory -Filter "PSUSandbox-*" -ErrorAction SilentlyContinue
    if (-not $sandboxDirs) {
        Write-Host "No sandboxes found." -ForegroundColor Yellow
    } else {
        Write-Host ""
        Write-Host "Existing sandboxes:" -ForegroundColor Cyan
        foreach ($dir in $sandboxDirs) {
            $cfgPath = Join-Path $dir.FullName "sandbox.json"
            if (Test-Path $cfgPath) {
                $cfg      = Get-Content $cfgPath -Raw | ConvertFrom-Json
                $props    = $cfg.PSObject.Properties
                $storedPid = if ($props['pid']) { $cfg.pid } else { $null }
                $running  = if ($storedPid) {
                    Get-Process -Id $storedPid -ErrorAction SilentlyContinue
                } else {
                    Get-Process -ErrorAction SilentlyContinue |
                        Where-Object { try { $_.Path -eq $cfg.serverExe } catch { $false } }
                }
                $status   = if ($running) { "RUNNING (PID $($running.Id))" } else { "stopped" }
                $sid      = if ($props['sandboxId'])  { $cfg.sandboxId }  else { '(unknown)' }
                $created  = if ($props['createdAt'])  { $cfg.createdAt }  else { 'unknown' }
                $url      = if ($props['url'])        { $cfg.url }        else { 'unknown' }
                $src      = if ($props['source'])     { $cfg.source }     else { 'cdn' }
                Write-Host "  $($dir.Name)" -ForegroundColor White
                Write-Host "    URL      : $url"
                Write-Host "    SandboxId: $sid"
                Write-Host "    Source   : $src"
                Write-Host "    Created  : $created"
                Write-Host "    Status   : $status"
            } else {
                Write-Host "  $($dir.Name)  (no sandbox.json)" -ForegroundColor DarkGray
            }
        }
        Write-Host ""
    }
    exit 0
}

# ---------------------------------------------------------------------------
# Resolve SandboxId
# ---------------------------------------------------------------------------
if ([string]::IsNullOrWhiteSpace($SandboxId)) {
    $SandboxId = [System.Guid]::NewGuid().ToString('N').Substring(0, 6)
    Write-Host "Generated SandboxId: $SandboxId" -ForegroundColor Cyan
} else {
    Write-Host "Using SandboxId    : $SandboxId" -ForegroundColor Cyan
}

# ---------------------------------------------------------------------------
# Directory layout
#
#   $SharedPsuDirectory\         Shared PSU binaries (per version, shared across sandboxes)
#     Universal.Server.exe
#     ...
#
#   $SandboxRoot\
#     data\         PSU application data
#       repository\
#     logs\
#     agent\logs\
#     Dashboard\
#     sandbox.json
#     Start-Sandbox.ps1
#     Remove-Sandbox.ps1
# ---------------------------------------------------------------------------
$SandboxRoot        = Join-Path $env:TEMP "PSUSandbox-${Version}-${SandboxId}"
$SharedPsuDirectory = Join-Path $env:TEMP "PSUBinaries-${Version}"
$DataDirectory      = Join-Path $SandboxRoot "data"
$configFile         = Join-Path $SandboxRoot "sandbox.json"

# ---------------------------------------------------------------------------
# -Teardown
# ---------------------------------------------------------------------------
if ($Teardown) {
    if (-not (Test-Path $SandboxRoot)) {
        Write-Host "Sandbox not found: $SandboxRoot" -ForegroundColor Yellow
        exit 0
    }

    Write-Host "Tearing down sandbox: $SandboxRoot" -ForegroundColor Cyan

    $stopped      = 0
    # Try stored PID first for a precise stop
    if (Test-Path $configFile) {
        $storedCfg = Get-Content $configFile -Raw | ConvertFrom-Json
        if ($storedCfg.PSObject.Properties['pid'] -and $storedCfg.pid) {
            $byPid = Get-Process -Id $storedCfg.pid -ErrorAction SilentlyContinue
            if ($byPid) {
                Write-Host "  Stopping PID $($byPid.Id) ($($byPid.Name)) [from sandbox.json]..." -ForegroundColor Yellow
                Stop-Process -Id $byPid.Id -Force -ErrorAction SilentlyContinue
                $stopped++
            }
        }
    }
    # Fallback: scan processes by path for any survivors
    $resolvedRoot = (Resolve-Path $SandboxRoot -ErrorAction SilentlyContinue)?.Path ?? $SandboxRoot
    Get-Process -ErrorAction SilentlyContinue | Where-Object {
        try { $_.Path -and $_.Path.StartsWith($resolvedRoot, [System.StringComparison]::OrdinalIgnoreCase) } catch { $false }
    } | ForEach-Object {
        Write-Host "  Stopping PID $($_.Id) ($($_.Name))..." -ForegroundColor Yellow
        Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
        $stopped++
    }
    if ($stopped -eq 0) { Write-Host "  No running processes found." -ForegroundColor DarkGray }
    if ($stopped -gt 0) { Start-Sleep -Seconds 2 }

    Remove-Item -Path $SandboxRoot -Recurse -Force
    Write-Host ""
    Write-Box @(
        "Sandbox $SandboxId torn down.",
        "Version : $Version",
        "Path    : $SandboxRoot"
    ) -BorderColor Yellow
    exit 0
}

# ---------------------------------------------------------------------------
# Create directory structure
# ---------------------------------------------------------------------------
foreach ($d in @(
    $SharedPsuDirectory,
    $DataDirectory,
    (Join-Path $DataDirectory "repository"),
    (Join-Path $SandboxRoot "logs"),
    (Join-Path $SandboxRoot "agent\logs"),
    (Join-Path $SandboxRoot "Dashboard")
)) {
    if (-not (Test-Path $d)) { New-Item -ItemType Directory -Path $d -Force | Out-Null }
}
Write-Host "Sandbox root  : $SandboxRoot" -ForegroundColor Cyan
Write-Host "Shared bins   : $SharedPsuDirectory" -ForegroundColor Cyan

# ---------------------------------------------------------------------------
# Download PSU binaries from CDN
# ---------------------------------------------------------------------------
$ZipFile = Join-Path $env:TEMP "Devolutions.PowerShellUniversal.win-x64.$Version.zip"

if (-not (Test-Path $ZipFile)) {
    $downloadUrl = "https://cdn.devolutions.net/download/Devolutions.PowerShellUniversal.win-x64.$Version.zip"
    Write-Host "Downloading $downloadUrl ..." -ForegroundColor Cyan
    Invoke-RestMethod $downloadUrl -OutFile $ZipFile
    Write-Host "Download complete." -ForegroundColor Green
} else {
    Write-Host "Zip already cached: $ZipFile" -ForegroundColor DarkGray
}

if (-not (Test-Path (Join-Path $SharedPsuDirectory "Universal.Server.exe")) -and
    -not (Test-Path (Join-Path $SharedPsuDirectory "Universal.Server"))) {
    Write-Host "Extracting to $SharedPsuDirectory ..." -ForegroundColor Cyan
    Expand-Archive -Path $ZipFile -DestinationPath $SharedPsuDirectory -Force
    Write-Host "Extraction complete." -ForegroundColor Green
} else {
    Write-Host "PSU binaries already extracted: $SharedPsuDirectory" -ForegroundColor DarkGray
}
$sourceLabel = "cdn:$Version"

# ---------------------------------------------------------------------------
# Locate server executable
# ---------------------------------------------------------------------------
$serverExe = Get-ChildItem -Path $SharedPsuDirectory -Filter "Universal.Server.exe" -Recurse -ErrorAction SilentlyContinue |
    Select-Object -First 1
if ($null -eq $serverExe) {
    $serverExe = Get-ChildItem -Path $SharedPsuDirectory -Filter "Universal.Server" -Recurse -ErrorAction SilentlyContinue |
        Select-Object -First 1
}
if ($null -eq $serverExe) { throw "Could not find Universal.Server executable under $SharedPsuDirectory" }

# ---------------------------------------------------------------------------
# Port selection — reuse stored port if sandbox.json exists, else pick free
# ---------------------------------------------------------------------------
if (Test-Path $configFile) {
    $storedConfig = Get-Content $configFile -Raw | ConvertFrom-Json
    $Port = $storedConfig.port
    Write-Host "Reusing stored port : $Port (from sandbox.json)" -ForegroundColor DarkGray
} else {
    $usedPorts = [System.Collections.Generic.HashSet[int]]::new()
    foreach ($conn in (Get-NetTCPConnection -ErrorAction SilentlyContinue)) {
        [void]$usedPorts.Add($conn.LocalPort)
    }
    $Port = $null
    for ($p = 5001; $p -le 6000; $p++) {
        if (-not $usedPorts.Contains($p)) { $Port = $p; break }
    }
    if ($null -eq $Port) { throw "No free port found in range 5001-6000." }
    Write-Host "Selected port : $Port" -ForegroundColor Cyan
}

# ---------------------------------------------------------------------------
# Environment variables
# ---------------------------------------------------------------------------

if (-not $DatabaseConnectionString -and $DatabaseType -eq "SQLite")
{
    $DatabaseConnectionString = "Data Source=$DataDirectory\psu.db"
}

$envVars = [ordered]@{
    Data__ConnectionString           = $DatabaseConnectionString
    Data__RepositoryPath             = "$DataDirectory\repository"
    SystemLogPath                    = "$SandboxRoot\logs\systemlog.txt"
    PsuAgentLogPath                  = "$SandboxRoot\agent\logs\log.txt"
    'Kestrel__Endpoints__HTTP__Url'  = "http://*:$Port"
    UniversalDashboard__AssetsFolder = "$SandboxRoot\Dashboard"
}

$Plugins = @($DatabaseType)

if ("MCP" -in $Features) {
    $Plugins += "PowerShellUniversal.Plugin.MCP"
}

if ("C#" -in $Features) {
    $Plugins += "PowerShellUniversal.Language.CSharp"
}

if ("YARP" -in $Features) {
    $Plugins += "PowerShellUniversal.Plugin.YARP"
}

$i = 0
foreach ($plugin in $Plugins) {
    $envVars["Plugins__$i"] = $plugin
    $i++
}

foreach ($key in $envVars.Keys) {
    [System.Environment]::SetEnvironmentVariable($key, $envVars[$key], 'Process')
}

# ---------------------------------------------------------------------------
# Save/update sandbox.json
# ---------------------------------------------------------------------------
$config = [ordered]@{
    version     = $Version
    sandboxId   = $SandboxId
    source      = $sourceLabel
    sandboxRoot = $SandboxRoot
    port        = $Port
    url         = "http://localhost:$Port"
    serverExe   = $serverExe.FullName
    pid         = $null
    envVars     = $envVars
    createdAt   = if (Test-Path $configFile) { (Get-Content $configFile -Raw | ConvertFrom-Json).createdAt } else { (Get-Date -Format "o") }
}
$config | ConvertTo-Json -Depth 5 | Set-Content -Path $configFile -Encoding UTF8

# ---------------------------------------------------------------------------
# Write Start-Sandbox.ps1
# ---------------------------------------------------------------------------
$startScript  = Join-Path $SandboxRoot "Start-Sandbox.ps1"
$removeScript = Join-Path $SandboxRoot "Remove-Sandbox.ps1"
$envLines     = $envVars.GetEnumerator() | ForEach-Object { "`$env:$($_.Key) = '$($_.Value)'" }

@"
# Auto-generated — re-run to restart this PSU sandbox without rebuilding.
# Version: $Version  SandboxId: $SandboxId  Source: $sourceLabel
Set-StrictMode -Version Latest
`$ErrorActionPreference = 'Stop'

$($envLines -join "`n")

Push-Location '$($serverExe.DirectoryName)'
try {
    `$proc = Start-Process -FilePath '$($serverExe.FullName)' -PassThru -NoNewWindow -RedirectStandardOutput '$SandboxRoot\logs\server-stdout.txt' -RedirectStandardError '$SandboxRoot\logs\server-stderr.txt'
    # Persist the new PID so teardown/list can target it directly
    `$cfg = Get-Content '$configFile' -Raw | ConvertFrom-Json
    `$cfg.pid = `$proc.Id
    `$cfg | ConvertTo-Json -Depth 5 | Set-Content -Path '$configFile' -Encoding UTF8
    Write-Host ""
    Write-Host "  Sandbox root : $SandboxRoot"
    Write-Host "  URL          : http://localhost:$Port"
    Write-Host "  Process ID   : `$(`$proc.Id)"
    Write-Host "  SandboxId    : $SandboxId"
    Write-Host ""
    `$proc.WaitForExit()
} finally {
    Pop-Location
}
"@ | Set-Content -Path $startScript -Encoding UTF8

# ---------------------------------------------------------------------------
# Write Remove-Sandbox.ps1
# ---------------------------------------------------------------------------
@"
# Auto-generated — stops and permanently deletes this sandbox.
# Version: $Version  SandboxId: $SandboxId
`$ErrorActionPreference = 'Stop'

Write-Host "Stopping processes for sandbox $SandboxId..." -ForegroundColor Cyan
`$resolvedRoot = (Resolve-Path '$SandboxRoot' -ErrorAction SilentlyContinue)?.Path ?? '$SandboxRoot'
Get-Process -ErrorAction SilentlyContinue | Where-Object {
    try { `$_.Path -and `$_.Path.StartsWith(`$resolvedRoot, [System.StringComparison]::OrdinalIgnoreCase) } catch { `$false }
} | ForEach-Object {
    Write-Host "  Stopping PID `$(`$_.Id)..." -ForegroundColor Yellow
    Stop-Process -Id `$_.Id -Force -ErrorAction SilentlyContinue
}
Start-Sleep -Seconds 2
Write-Host "Removing $SandboxRoot ..." -ForegroundColor Cyan
Remove-Item -Path '$SandboxRoot' -Recurse -Force
Write-Host "Done." -ForegroundColor Green
"@ | Set-Content -Path $removeScript -Encoding UTF8

Write-Host "Start script  : $startScript" -ForegroundColor DarkGray
Write-Host "Remove script : $removeScript" -ForegroundColor DarkGray

# ---------------------------------------------------------------------------
# Seed repository from ConfigurationDirectory or GitRepo
# ---------------------------------------------------------------------------
if (-not [string]::IsNullOrWhiteSpace($ConfigurationDirectory)) {
    if (-not (Test-Path $ConfigurationDirectory)) {
        throw "ConfigurationDirectory not found: $ConfigurationDirectory"
    }
    $repoDirectory = Join-Path $DataDirectory "repository"
    Write-Host "Seeding repository from: $ConfigurationDirectory" -ForegroundColor Cyan
    Copy-Item -Path (Join-Path $ConfigurationDirectory "*") -Destination $repoDirectory -Recurse -Force
    Write-Host "Repository seeded." -ForegroundColor Green
} elseif ($PSCmdlet.ParameterSetName -eq 'FromGit') {
    $repoDirectory = Join-Path $DataDirectory "repository"
    Write-Host "Cloning repository from: $GitRepo" -ForegroundColor Cyan
    git clone $GitRepo $repoDirectory
    Write-Host "Repository cloned." -ForegroundColor Green
}

# ---------------------------------------------------------------------------
# Launch PSU server
# ---------------------------------------------------------------------------
Push-Location $serverExe.DirectoryName
try {
    $proc = Start-Process -FilePath $serverExe.FullName -PassThru -NoNewWindow -RedirectStandardOutput "$SandboxRoot\logs\server-stdout.txt" -RedirectStandardError "$SandboxRoot\logs\server-stderr.txt"

    # Persist the PID so teardown/list can target it directly
    $savedConfig = Get-Content $configFile -Raw | ConvertFrom-Json
    $savedConfig.pid = $proc.Id
    $savedConfig | ConvertTo-Json -Depth 5 | Set-Content -Path $configFile -Encoding UTF8

    Write-Host ""
    $summaryLines = @(
        "PSU Sandbox Started",
        "  Version    : $Version",
        "  Source     : $sourceLabel",
        "  SandboxId  : $SandboxId",
        "  URL        : http://localhost:$Port",
        "  Process ID : $($proc.Id)",
        "  Root       : $SandboxRoot",
        "  Relaunch   : $startScript",
        "  Teardown   : $removeScript",
        "  Features    : $($Features -join ', ')",
        "  Database    : $DatabaseType",
        "  Repo source  : $($ConfigurationDirectory ?? $GitRepo ?? '(none)')",
        "  Default credentials: admin / admin"
    )

    try {
        $Status = Invoke-RestMethod -Uri "http://localhost:$Port/api/v1/alive" -ErrorAction SilentlyContinue -SkipHttpErrorCheck
    } catch {
        $Status = $null
    }
    
    while($null -eq $Status -or $Status.loading) {
        Write-Host "Waiting for PSU to start..." -ForegroundColor Cyan
        Start-Sleep -Seconds 2
        try {
            $Status = Invoke-RestMethod -Uri "http://localhost:$Port/api/v1/alive" -ErrorAction SilentlyContinue -SkipHttpErrorCheck
        } catch {
            $Status = $null
        }
    }

    $null = Invoke-RestMethod -Uri "http://localhost:$Port/api/v1/first-run" -Method Post -Body (@{ userName = "admin"; password = "admin" } | ConvertTo-Json) -ContentType "application/json"

    Start-Process "http://localhost:$Port"

    Write-Box $summaryLines
    Write-Host ""
    Write-Host "To stop  : Stop-Process -Id $($proc.Id)" -ForegroundColor DarkGray
    Write-Host "To remove: pwsh '$removeScript'" -ForegroundColor DarkGray
    Write-Host "To list  : pwsh '$PSCommandPath' -List" -ForegroundColor DarkGray
    Write-Host ""
} finally {
    Pop-Location
}