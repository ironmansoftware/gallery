# Ant Design Dashboard Framework

This folder scaffolds an alternate PowerShell Universal dashboard framework that keeps the PSU transport and descriptor contract while rendering with Ant Design.

## Design choices

- React, TypeScript, Vite, SignalR, Zustand, Zod, and TanStack Query provide the client runtime foundation.
- `withComponentFeatures` is imported from the published `universal-dashboard` npm package instead of being reimplemented locally.
- Static assets are built into `dist` and exposed through `.universal/publishedFolders.ps1` at `/frameworks/ant-design`.

## Build

```powershell
npm install
npm run build
```

## Local harness workflow

Framework iteration should run against the harness first.

From this folder:

```powershell
npm install
npm run harness
```

That builds the Ant Design bundle and starts the harness from [Apps/Frameworks/Harness](d:/git/powershell-universal-gallery/Apps/Frameworks/Harness) on `http://127.0.0.1:5057`.

The AntDesign harness definition mounts this framework bundle and uses `New-AntDesignDemo` by default, so local work can stay focused on the framework transport contract without starting full PSU.

From [Apps/Frameworks](d:/git/powershell-universal-gallery/Apps/Frameworks), you can also use the shared launcher:

```powershell
.\Start-Framework.ps1 .\AntDesign
.\Start-Framework.ps1 .\AntDesign -Build
```

The `-Build` switch runs the framework build before starting the harness.

## Module helpers

Importing the PowerShell module exposes:

- `Get-PSUAntDesignFrameworkAssetBasePath`
- `Get-PSUAntDesignFrameworkEntryPoint`
- `New-UDAntDesignText`
- `New-UDAntDesignButton`
- `New-UDAntDesignCheckbox`
- `New-UDAntDesignCol`
- `New-UDAntDesignInput`
- `New-UDAntDesignLayout`
- `New-UDAntDesignLayoutContent`
- `New-UDAntDesignLayoutFooter`
- `New-UDAntDesignLayoutHeader`
- `New-UDAntDesignLayoutSider`
- `New-UDAntDesignRate`
- `New-UDAntDesignRow`
- `New-UDAntDesignSwitch`
- `New-UDAntDesignTypography`
- `Show-AntDesignMessage`
- `New-AntDesignDemo`
- `New-AntDesignDemoApp`

The second helper resolves the current build manifest and returns the hashed asset paths for the compiled entrypoint.
`New-AntDesignDemo` returns a component documentation shell for the framework, with per-component pages and live examples generated from the module comment-based help. `New-AntDesignDemoApp` wraps that content in `New-UDApp` for PSU-hosted use.
The `Endpoint` type used by interactive component helpers is supplied by PowerShell Universal or by the local harness runner.

## Scope of the scaffold

The current scaffold includes:

- strict TypeScript and Vite build configuration
- hashed build assets with manifest-driven entrypoint resolution for cache busting
- a published-folder module layout for PSU
- descriptor schemas and runtime state store
- dashboard bootstrap over `/api/internal/dashboard`
- SignalR connection scaffolding for `/dashboardhub`
- server-push support for Ant Design global messages via `Show-AntDesignMessage`
- a global component registry with lazy-loaded Ant Design components wrapped by `withComponentFeatures`
- a help-driven component documentation shell with live previews for the documented examples

## Demo usage

Load the module from PowerShell Universal or through the harness runner, then call:

```powershell
New-AntDesignDemo
```

The default demo now opens an Ant Design-style docs experience. The button, checkbox, grid, input, layout, rate, switch, and typography pages are generated from comment-based help, and the preview cards are rendered by executing those documented examples.

Inside PowerShell Universal, you can use:

```powershell
New-AntDesignDemoApp
```

For harness-hosted iteration, open `http://127.0.0.1:5057` after `npm run harness`.

## Playwright

Browser-level tests run against the harness by default.

```powershell
npm run test:e2e:install
npm run test:e2e
```

The shared fixture in [Apps/Frameworks/AntDesign/testing/playwright/harnessFixture.ts](d:/git/powershell-universal-gallery/Apps/Frameworks/AntDesign/testing/playwright/harnessFixture.ts) drives server-push scenarios through the harness admin endpoints:

- `POST /api/harness/messages`
- `POST /api/harness/downloads/{id}`

The runtime now handles server-pushed Ant Design global messages in addition to bootstrap and connection status.
