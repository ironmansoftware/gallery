# PowerShell Universal NuGet API

This module provides a small NuGet V3 package feed for PowerShell Universal. It stores packages on disk, generates flat-container and registration metadata, and exposes NuGet-compatible discovery, search, autocomplete, package retrieval, unlist, relist, and management endpoints.

## Endpoints

- `GET /nuget/v3/index.json` - NuGet V3 service index.
- `GET /nuget/v3-flatcontainer/{id-lower}/index.json` - Package version list.
- `GET /nuget/v3-flatcontainer/{id-lower}/{version-lower}/{id-lower}.{version-lower}.nupkg` - Package content.
- `GET /nuget/v3-flatcontainer/{id-lower}/{version-lower}/{id-lower}.nuspec` - Package manifest.
- `GET /nuget/v3/registration/{id-lower}/index.json` - Registration metadata.
- `GET /nuget/v3/registration/{id-lower}/{version-lower}.json` - Registration leaf metadata.
- `GET /nuget/static/v3-flatcontainer/...` and `GET /nuget/static/v3/registration/...` - Published-folder mounts for generated package and metadata files.
- `GET /nuget/query` - NuGet V3 search.
- `GET /nuget/autocomplete` - NuGet V3 package ID and version autocomplete.
- `PUT|POST /nuget/api/v2/package` - Publish raw `.nupkg` bytes. Requires PSU authentication and the `Administrator` or `NuGet Publisher` role.
- `DELETE /nuget/api/v2/package/{id}/{version}` - Unlist a package. Requires PSU authentication and the `Administrator` or `NuGet Publisher` role.
- `POST /nuget/api/v2/package/{id}/{version}` - Relist a package. Requires PSU authentication and the `Administrator` or `NuGet Publisher` role.
- `GET /nuget/package` - List catalog packages. Requires PSU authentication and the `Administrator` or `NuGet Publisher` role.
- `DELETE /nuget/package/{id}/{version}` - Hard-delete package content and catalog metadata. Requires PSU authentication and the `Administrator` or `NuGet Publisher` role.

## Configuration

Set these environment variables before starting PowerShell Universal when you need to override defaults.

- `PSU_NUGET_FEED_PATH` - Directory used to store packages, catalog data, and generated metadata. Defaults to `.nuget` under the PSU repository path when available, otherwise `%ProgramData%\PowerShellUniversal\NuGet`.
- `PSU_NUGET_BASE_URL` - Public feed root URL, such as `https://psu.contoso.com/nuget`. The service index can infer this from request headers, but static registration metadata is generated with this value during package publish.

## Publishing

PowerShell Universal endpoints do not support `multipart/form-data` file uploads. Because standard `nuget.exe push` sends packages as multipart form data, publish with raw package bytes instead.

```powershell
$token = '<PSU app token>'
$publish = 'https://psu.contoso.com/nuget/api/v2/package'

Invoke-WebRequest -Uri $publish -Method Put -InFile .\MyPackage.1.0.0.nupkg -ContentType 'application/octet-stream' -Headers @{
    Authorization = "Bearer $token"
}
```

After publishing, clients can restore or install from the V3 source.

```powershell
dotnet nuget add source https://psu.contoso.com/nuget/v3/index.json -n PSU
nuget.exe install MyPackage -Source https://psu.contoso.com/nuget/v3/index.json
```

```powershell
Register-PSResourceRepository -Name PSU -Uri https://psu.contoso.com/nuget/v3/index.json -Trusted
Install-PSResource -Name MyPackage -Repository PSU
```

## Maintenance

You can use the module directly to initialize or repair metadata.

```powershell
Import-Module PowerShellUniversal.NuGet
Initialize-PSUNuGetRepository
Update-PSUNuGetStaticMetadata -BaseUrl 'https://psu.contoso.com/nuget'
Get-PSUNuGetPackage -IncludeUnlisted
```