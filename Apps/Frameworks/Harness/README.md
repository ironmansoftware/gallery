# PSU Framework Harness

This folder contains a lightweight ASP.NET Core host that mimics the PowerShell Universal dashboard framework contract without requiring the full PSU runtime.

The harness focuses on the framework-facing surface:

- serving framework static assets from published-folder style request paths
- returning dashboard bootstrap data from PowerShell scripts
- executing PowerShell endpoint scripts for HTTP and websocket events
- sending and receiving SignalR messages on `/dashboardhub`
- storing session-state fallbacks and temporary downloads

## What it hosts

The harness exposes the same compatibility surface a custom framework cares about:

- `GET /api/internal/dashboard`
- `GET /api/internal/component/element/{id}`
- `POST /api/internal/component/element/{id}`
- `POST /api/internal/component/element/sessionState/{requestId}`
- `GET /api/internal/dashboard/download/{dashboardId}/{id}`
- SignalR hub at `/dashboardhub`

It also exposes small test-oriented admin endpoints:

- `GET /api/harness/connections`
- `POST /api/harness/messages`
- `POST /api/harness/downloads/{id}`

These make the harness useful for Playwright coverage without needing a full PSU instance.

## Run

From this folder:

```powershell
dotnet run --project .\src\PowerShellUniversal.Frameworks.Harness\PowerShellUniversal.Frameworks.Harness.csproj --urls http://localhost:5057
```

Then open `http://localhost:5057`.

The default sample definition mounts the Ant Design framework bundle from [Apps/Frameworks/AntDesign/dist](d:/git/powershell-universal-gallery/Apps/Frameworks/AntDesign/dist), resolves the current `manifest.json`, and loads a small demo dashboard without hardcoding hashed asset names.

## Definition file

The harness reads a PowerShell definition script from `Harness:DefinitionPath` in [Apps/Frameworks/Harness/src/PowerShellUniversal.Frameworks.Harness/appsettings.json](d:/git/powershell-universal-gallery/Apps/Frameworks/Harness/src/PowerShellUniversal.Frameworks.Harness/appsettings.json).

The default definition is [Apps/Frameworks/Harness/sample/harness.ps1](d:/git/powershell-universal-gallery/Apps/Frameworks/Harness/sample/harness.ps1).

The definition script returns a hashtable with these keys:

- `DashboardScript`: path to a PowerShell script that returns either the full bootstrap object or just the root dashboard descriptor
- `EndpointRoot`: folder containing endpoint scripts named `{endpointId}.ps1`
- `Endpoints`: optional explicit endpoint-id to script-path map
- `StaticAssets`: request-path mappings for framework bundles
- `Shell`: simple host page settings such as title, mount id, scripts, and styles

Example:

```powershell
$antDesignDistPath = Join-Path $PSScriptRoot '..\..\AntDesign\dist'
$antDesignAssetBasePath = '/frameworks/ant-design'
$antDesignEntryPoint = Get-AntDesignHarnessEntryPoint -DistPath $antDesignDistPath -BasePath $antDesignAssetBasePath

@{
    DashboardScript = Join-Path $PSScriptRoot 'dashboard.ps1'
    EndpointRoot = Join-Path $PSScriptRoot 'endpoints'
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
```

## PowerShell script contract

Each script executes with two ambient variables:

- `$HarnessContext`: request or websocket context information
- `$PsuHarness`: helper API instance

The harness also exposes script-location helpers for relative path resolution:

- `$HarnessScriptRoot`
- `$HarnessScriptPath`

Helper functions are also available:

- `Send-PSUHarnessMessage`
- `Set-PSUHarnessDownload`
- `Set-PSUHarnessSessionState`
- `Get-PSUHarnessConnections`

`$HarnessContext` includes fields such as:

- `DashboardId`
- `SessionId`
- `PageId`
- `ConnectionId`
- `EndpointId`
- `Method`
- `EventName`
- `EventData`
- `Location`
- `Query`
- `Headers`
- `Cookies`
- `Form`
- `Body`
- `JsonBody`
- `Files`

Endpoint scripts can return hashtables, arrays, strings, and other serializable values. The harness normalizes the output to JSON.

## Playwright usage

The harness is meant to be the default browser host for framework tests.

Typical flow:

1. Start the harness.
2. Navigate Playwright to `/`.
3. Use `POST /api/harness/messages` to push `setState`, `addElement`, `download`, or other websocket messages.
4. Use `POST /api/harness/downloads/{id}` before sending a `download` message when download flows need to be exercised.

## Notes

- Static asset mappings are loaded at startup. If you change `StaticAssets`, restart the harness.
- Dashboard and endpoint scripts are reloaded when the definition file changes.
- Authentication, authorization, and PSU-specific variable scoping are intentionally out of scope here.
