Set-StrictMode -Version Latest

function Get-PSUNuGetFeedPath {
    [CmdletBinding()]
    param()

    if ($env:PSU_NUGET_FEED_PATH) {
        return $env:PSU_NUGET_FEED_PATH
    }

    if ($env:Data__RepositoryPath) {
        return (Join-Path $env:Data__RepositoryPath '.nuget')
    }

    Join-Path (Join-Path ([Environment]::GetFolderPath('CommonApplicationData')) 'PowerShellUniversal') 'NuGet'
}

function Get-PSUNuGetRequestBaseUrl {
    [CmdletBinding()]
    param(
        [hashtable]$Headers
    )

    if ($env:PSU_NUGET_BASE_URL) {
        return $env:PSU_NUGET_BASE_URL.TrimEnd('/')
    }

    $scheme = 'http'
    $hostName = $null

    if ($Headers) {
        if ($Headers.ContainsKey('X-Forwarded-Proto')) {
            $scheme = ($Headers['X-Forwarded-Proto'] -split ',')[0].Trim()
        }
        elseif ($Headers.ContainsKey('X-Forwarded-Scheme')) {
            $scheme = ($Headers['X-Forwarded-Scheme'] -split ',')[0].Trim()
        }

        if ($Headers.ContainsKey('X-Forwarded-Host')) {
            $hostName = ($Headers['X-Forwarded-Host'] -split ',')[0].Trim()
        }
        elseif ($Headers.ContainsKey('Host')) {
            $hostName = ($Headers['Host'] -split ',')[0].Trim()
        }
    }

    if (-not $hostName) {
        $hostName = 'localhost:5000'
    }

    $schemeSeparator = ([char]58).ToString() + '//'
    '{0}{1}{2}/nuget' -f $scheme, $schemeSeparator, $hostName
}

function Join-PSUNuGetUrl {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$BaseUrl,

        [Parameter(Mandatory)]
        [string[]]$Segment
    )

    $base = $BaseUrl.TrimEnd('/')
    $path = ($Segment | ForEach-Object { $_.Trim('/') }) -join '/'
    if ([string]::IsNullOrWhiteSpace($path)) {
        return $base
    }

    "$base/$path"
}

function Test-PSUNuGetSafeSegment {
    [CmdletBinding()]
    param([string]$Value)

    -not [string]::IsNullOrWhiteSpace($Value) -and
    $Value -match '^[A-Za-z0-9_.-]+$' -and
    -not $Value.Contains('..')
}

function New-PSUNuGetJsonFileResponse {
    [CmdletBinding()]
    param([string]$Path)

    if (-not (Test-Path $Path)) {
        return New-PSUApiResponse -StatusCode 404 -Body 'The requested NuGet metadata file was not found.'
    }

    New-PSUApiResponse -StatusCode 200 -ContentType 'application/json' -Body (Get-Content -Path $Path -Raw)
}

function Initialize-PSUNuGetRepository {
    [CmdletBinding()]
    param(
        [string]$Path = (Get-PSUNuGetFeedPath)
    )

    $directories = @(
        $Path,
        (Join-Path $Path '_catalog'),
        (Join-Path $Path 'v3-flatcontainer'),
        (Join-Path (Join-Path $Path 'v3') 'registration')
    )

    foreach ($directory in $directories) {
        if (-not (Test-Path $directory)) {
            New-Item -ItemType Directory -Path $directory -Force | Out-Null
        }
    }

    $catalogFile = Join-Path (Join-Path $Path '_catalog') 'packages.json'
    if (-not (Test-Path $catalogFile)) {
        '[]' | Set-Content -Path $catalogFile -Encoding utf8
    }

    Get-Item $Path
}

function Get-PSUNuGetCatalogFile {
    [CmdletBinding()]
    param(
        [string]$Path = (Get-PSUNuGetFeedPath)
    )

    Initialize-PSUNuGetRepository -Path $Path | Out-Null
    Join-Path (Join-Path $Path '_catalog') 'packages.json'
}

function Read-PSUNuGetCatalog {
    [CmdletBinding()]
    param(
        [string]$Path = (Get-PSUNuGetFeedPath)
    )

    $catalogFile = Get-PSUNuGetCatalogFile -Path $Path
    $content = Get-Content -Path $catalogFile -Raw
    if ([string]::IsNullOrWhiteSpace($content)) {
        return @()
    }

    @($content | ConvertFrom-Json -Depth 50)
}

function Write-PSUNuGetCatalog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [object[]]$Package,

        [string]$Path = (Get-PSUNuGetFeedPath)
    )

    $catalogFile = Get-PSUNuGetCatalogFile -Path $Path
    $sortedPackages = @($Package | Sort-Object LowerId, @{ Expression = { ConvertTo-PSUNuGetVersionSortKey -Version $_.NormalizedVersion } })
    ConvertTo-Json -InputObject $sortedPackages -Depth 50 | Set-Content -Path $catalogFile -Encoding utf8
}

function Get-PSUNuGetNuspecValue {
    param(
        [Parameter(Mandatory)]
        [System.Xml.XmlElement]$Metadata,

        [Parameter(Mandatory)]
        [string]$Name
    )

    $node = $Metadata.ChildNodes | Where-Object { $_.LocalName -eq $Name } | Select-Object -First 1
    if ($node) {
        return $node.InnerText.Trim()
    }

    $null
}

function ConvertTo-PSUNuGetBoolean {
    param([string]$Value)

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return $false
    }

    [string]::Equals($Value, 'true', [StringComparison]::OrdinalIgnoreCase)
}

function ConvertTo-PSUNuGetStringArray {
    param([string]$Value)

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return @()
    }

    @($Value -split '[,\s]+' | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
}

function ConvertTo-PSUNuGetNormalizedVersion {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Version
    )

    $withoutMetadata = ($Version -split '\+', 2)[0]
    $versionParts = $withoutMetadata -split '-', 2
    $mainVersion = $versionParts[0]
    $prerelease = if ($versionParts.Count -gt 1) { $versionParts[1].ToLowerInvariant() } else { $null }

    $numbers = @($mainVersion.Split('.') | ForEach-Object {
            if ($_ -match '^\d+$') {
                [int]$_
            }
            else {
                throw "Version '$Version' is not a valid NuGet version."
            }
        })

    while ($numbers.Count -lt 3) {
        $numbers += 0
    }

    while ($numbers.Count -gt 3 -and $numbers[-1] -eq 0) {
        $numbers = @($numbers[0..($numbers.Count - 2)])
    }

    $normalized = ($numbers | ForEach-Object { $_.ToString().ToLowerInvariant() }) -join '.'
    if ($prerelease) {
        return "$normalized-$prerelease"
    }

    $normalized
}

function ConvertTo-PSUNuGetVersionSortKey {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Version
    )

    $normalized = ConvertTo-PSUNuGetNormalizedVersion -Version $Version
    $parts = $normalized -split '-', 2
    $numbers = @($parts[0].Split('.') | ForEach-Object { '{0:D8}' -f [int]$_ })

    while ($numbers.Count -lt 4) {
        $numbers += '00000000'
    }

    $releaseKey = if ($parts.Count -gt 1) { "0-$($parts[1])" } else { '1' }
    "$(($numbers -join '.'))-$releaseKey"
}

function Test-PSUNuGetPrereleaseVersion {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Version
    )

    $Version -match '-'
}

function Get-PSUNuGetDependencyGroups {
    param(
        [Parameter(Mandatory)]
        [System.Xml.XmlElement]$Metadata,

        [Parameter(Mandatory)]
        [string]$BaseUrl
    )

    $dependenciesNode = $Metadata.ChildNodes | Where-Object { $_.LocalName -eq 'dependencies' } | Select-Object -First 1
    if (-not $dependenciesNode) {
        return @()
    }

    $groups = @()
    $groupNodes = @($dependenciesNode.ChildNodes | Where-Object { $_.LocalName -eq 'group' })

    if ($groupNodes.Count -eq 0) {
        $dependencyItems = @($dependenciesNode.ChildNodes | Where-Object { $_.LocalName -eq 'dependency' })
        if ($dependencyItems.Count -gt 0) {
            $groups += [ordered]@{
                dependencies = @($dependencyItems | ForEach-Object {
                        $dependencyId = $_.GetAttribute('id')
                        [ordered]@{
                            id           = $dependencyId
                            range        = $_.GetAttribute('version')
                            registration = (Join-PSUNuGetUrl -BaseUrl $BaseUrl -Segment @('v3/registration', $dependencyId.ToLowerInvariant(), 'index.json'))
                        }
                    })
            }
        }

        return $groups
    }

    foreach ($groupNode in $groupNodes) {
        $dependencies = @($groupNode.ChildNodes | Where-Object { $_.LocalName -eq 'dependency' } | ForEach-Object {
                $dependencyId = $_.GetAttribute('id')
                [ordered]@{
                    id           = $dependencyId
                    range        = $_.GetAttribute('version')
                    registration = (Join-PSUNuGetUrl -BaseUrl $BaseUrl -Segment @('v3/registration', $dependencyId.ToLowerInvariant(), 'index.json'))
                }
            })

        $group = [ordered]@{
            dependencies = $dependencies
        }

        $targetFramework = $groupNode.GetAttribute('targetFramework')
        if (-not [string]::IsNullOrWhiteSpace($targetFramework)) {
            $group.targetFramework = $targetFramework
        }

        $groups += $group
    }

    $groups
}

function Get-PSUNuGetPackageTypes {
    param(
        [Parameter(Mandatory)]
        [System.Xml.XmlElement]$Metadata
    )

    $packageTypesNode = $Metadata.ChildNodes | Where-Object { $_.LocalName -eq 'packageTypes' } | Select-Object -First 1
    if (-not $packageTypesNode) {
        return @(@{ name = 'Dependency' })
    }

    $packageTypes = @($packageTypesNode.ChildNodes | Where-Object { $_.LocalName -eq 'packageType' } | ForEach-Object {
            [ordered]@{
                name = $_.GetAttribute('name')
            }
        })

    if ($packageTypes.Count -eq 0) {
        return @(@{ name = 'Dependency' })
    }

    $packageTypes
}

function Get-PSUNuGetPackageMetadata {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$PackagePath,

        [Parameter(Mandatory)]
        [string]$BaseUrl
    )

    Add-Type -AssemblyName System.IO.Compression.FileSystem

    $archive = [System.IO.Compression.ZipFile]::OpenRead($PackagePath)
    try {
        $nuspecEntry = $archive.Entries | Where-Object { $_.FullName -like '*.nuspec' } | Select-Object -First 1
        if (-not $nuspecEntry) {
            throw [ArgumentException]::new('The package does not contain a .nuspec file.')
        }

        $reader = [System.IO.StreamReader]::new($nuspecEntry.Open())
        try {
            $nuspecContent = $reader.ReadToEnd()
        }
        finally {
            $reader.Dispose()
        }

        [xml]$nuspec = $nuspecContent
        $metadata = $nuspec.DocumentElement.ChildNodes | Where-Object { $_.LocalName -eq 'metadata' } | Select-Object -First 1
        if (-not $metadata) {
            throw [ArgumentException]::new('The package .nuspec file does not contain metadata.')
        }

        $id = Get-PSUNuGetNuspecValue -Metadata $metadata -Name 'id'
        $version = Get-PSUNuGetNuspecValue -Metadata $metadata -Name 'version'

        if ([string]::IsNullOrWhiteSpace($id) -or [string]::IsNullOrWhiteSpace($version)) {
            throw [ArgumentException]::new('The package .nuspec file must contain id and version metadata.')
        }

        [ordered]@{
            Id                       = $id
            Version                  = $version
            LowerId                  = $id.ToLowerInvariant()
            NormalizedVersion        = ConvertTo-PSUNuGetNormalizedVersion -Version $version
            Authors                  = ConvertTo-PSUNuGetStringArray -Value (Get-PSUNuGetNuspecValue -Metadata $metadata -Name 'authors')
            Owners                   = ConvertTo-PSUNuGetStringArray -Value (Get-PSUNuGetNuspecValue -Metadata $metadata -Name 'owners')
            Description              = Get-PSUNuGetNuspecValue -Metadata $metadata -Name 'description'
            Summary                  = Get-PSUNuGetNuspecValue -Metadata $metadata -Name 'summary'
            Tags                     = ConvertTo-PSUNuGetStringArray -Value (Get-PSUNuGetNuspecValue -Metadata $metadata -Name 'tags')
            Title                    = Get-PSUNuGetNuspecValue -Metadata $metadata -Name 'title'
            ProjectUrl               = Get-PSUNuGetNuspecValue -Metadata $metadata -Name 'projectUrl'
            IconUrl                  = Get-PSUNuGetNuspecValue -Metadata $metadata -Name 'iconUrl'
            LicenseUrl               = Get-PSUNuGetNuspecValue -Metadata $metadata -Name 'licenseUrl'
            LicenseExpression        = Get-PSUNuGetNuspecValue -Metadata $metadata -Name 'license'
            Language                 = Get-PSUNuGetNuspecValue -Metadata $metadata -Name 'language'
            MinClientVersion         = $metadata.GetAttribute('minClientVersion')
            RequireLicenseAcceptance = ConvertTo-PSUNuGetBoolean -Value (Get-PSUNuGetNuspecValue -Metadata $metadata -Name 'requireLicenseAcceptance')
            DependencyGroups         = Get-PSUNuGetDependencyGroups -Metadata $metadata -BaseUrl $BaseUrl
            PackageTypes             = Get-PSUNuGetPackageTypes -Metadata $metadata
            NuspecContent            = $nuspecContent
        }
    }
    finally {
        $archive.Dispose()
    }
}

function New-PSUNuGetCatalogEntry {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [object]$Package,

        [Parameter(Mandatory)]
        [string]$BaseUrl
    )

    $flatContainerUrl = Join-PSUNuGetUrl -BaseUrl $BaseUrl -Segment @('v3-flatcontainer', $Package.LowerId, $Package.NormalizedVersion, "$($Package.LowerId).$($Package.NormalizedVersion).nupkg")
    $catalogEntry = [ordered]@{
        '@id'                    = (Join-PSUNuGetUrl -BaseUrl $BaseUrl -Segment @('v3/registration', $Package.LowerId, "$($Package.NormalizedVersion).json"))
        '@type'                  = 'PackageDetails'
        authors                  = @($Package.Authors)
        dependencyGroups         = @($Package.DependencyGroups)
        description              = $Package.Description
        iconUrl                  = $Package.IconUrl
        id                       = $Package.Id
        language                 = $Package.Language
        licenseUrl               = $Package.LicenseUrl
        listed                   = [bool]$Package.Listed
        minClientVersion         = $Package.MinClientVersion
        packageContent           = $flatContainerUrl
        packageTypes             = @($Package.PackageTypes)
        projectUrl               = $Package.ProjectUrl
        published                = if ($Package.Listed) { $Package.Published } else { '1900-01-01T00:00:00Z' }
        requireLicenseAcceptance = [bool]$Package.RequireLicenseAcceptance
        summary                  = $Package.Summary
        tags                     = @($Package.Tags)
        title                    = $Package.Title
        version                  = $Package.Version
    }

    if ($Package.LicenseExpression) {
        $catalogEntry.licenseExpression = $Package.LicenseExpression
    }

    $catalogEntry
}

function New-PSUNuGetRegistrationLeaf {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [object]$Package,

        [Parameter(Mandatory)]
        [string]$BaseUrl
    )

    $leafUrl = Join-PSUNuGetUrl -BaseUrl $BaseUrl -Segment @('v3/registration', $Package.LowerId, "$($Package.NormalizedVersion).json")
    $packageContentUrl = Join-PSUNuGetUrl -BaseUrl $BaseUrl -Segment @('v3-flatcontainer', $Package.LowerId, $Package.NormalizedVersion, "$($Package.LowerId).$($Package.NormalizedVersion).nupkg")
    [ordered]@{
        '@id'          = $leafUrl
        '@type'        = 'Package'
        catalogEntry   = (New-PSUNuGetCatalogEntry -Package $Package -BaseUrl $BaseUrl)
        listed         = [bool]$Package.Listed
        packageContent = $packageContentUrl
        published      = if ($Package.Listed) { $Package.Published } else { '1900-01-01T00:00:00Z' }
        registration   = (Join-PSUNuGetUrl -BaseUrl $BaseUrl -Segment @('v3/registration', $Package.LowerId, 'index.json'))
    }
}

function Update-PSUNuGetStaticMetadata {
    [CmdletBinding()]
    param(
        [string]$Path = (Get-PSUNuGetFeedPath),

        [string]$BaseUrl = $(if ($env:PSU_NUGET_BASE_URL) { $env:PSU_NUGET_BASE_URL } else { 'http://localhost:5000/nuget' })
    )

    Initialize-PSUNuGetRepository -Path $Path | Out-Null
    $packages = @(Read-PSUNuGetCatalog -Path $Path)
    $registrationRoot = Join-Path (Join-Path $Path 'v3') 'registration'

    if (Test-Path $registrationRoot) {
        Remove-Item -Path $registrationRoot -Recurse -Force
    }
    New-Item -ItemType Directory -Path $registrationRoot -Force | Out-Null

    foreach ($packageGroup in ($packages | Group-Object LowerId)) {
        $lowerId = $packageGroup.Name
        $sortedPackages = @($packageGroup.Group | Sort-Object @{ Expression = { ConvertTo-PSUNuGetVersionSortKey -Version $_.NormalizedVersion } })

        $flatPackagePath = Join-Path (Join-Path $Path 'v3-flatcontainer') $lowerId
        if (-not (Test-Path $flatPackagePath)) {
            New-Item -ItemType Directory -Path $flatPackagePath -Force | Out-Null
        }

        [ordered]@{
            versions = @($sortedPackages | ForEach-Object { $_.NormalizedVersion })
        } | ConvertTo-Json -Depth 10 | Set-Content -Path (Join-Path $flatPackagePath 'index.json') -Encoding utf8

        $registrationPackagePath = Join-Path $registrationRoot $lowerId
        New-Item -ItemType Directory -Path $registrationPackagePath -Force | Out-Null

        $leaves = @($sortedPackages | ForEach-Object {
                $leaf = New-PSUNuGetRegistrationLeaf -Package $_ -BaseUrl $BaseUrl
                $leaf | ConvertTo-Json -Depth 50 | Set-Content -Path (Join-Path $registrationPackagePath "$($_.NormalizedVersion).json") -Encoding utf8
                $leaf
            })

        if ($leaves.Count -gt 0) {
            $lowerVersion = $sortedPackages[0].NormalizedVersion
            $upperVersion = $sortedPackages[-1].NormalizedVersion
            [ordered]@{
                count = 1
                items = @(
                    [ordered]@{
                        '@id' = "$(Join-PSUNuGetUrl -BaseUrl $BaseUrl -Segment @('v3/registration', $lowerId, 'index.json'))#page/$lowerVersion/$upperVersion"
                        count = $leaves.Count
                        items = $leaves
                        lower = $lowerVersion
                        upper = $upperVersion
                    }
                )
            } | ConvertTo-Json -Depth 50 | Set-Content -Path (Join-Path $registrationPackagePath 'index.json') -Encoding utf8
        }
    }
}

function Publish-PSUNuGetPackage {
    [CmdletBinding()]
    param(
        [byte[]]$Data,

        [string]$PackagePath,

        [string]$Path = (Get-PSUNuGetFeedPath),

        [string]$BaseUrl = $(if ($env:PSU_NUGET_BASE_URL) { $env:PSU_NUGET_BASE_URL } else { 'http://localhost:5000/nuget' }),

        [switch]$Force
    )

    Initialize-PSUNuGetRepository -Path $Path | Out-Null

    $temporaryPackage = $null
    if (-not $PackagePath) {
        if (-not $Data -or $Data.Length -eq 0) {
            throw [ArgumentException]::new('The request did not include package bytes. Send the .nupkg as the raw request body.')
        }

        $temporaryPackage = Join-Path ([IO.Path]::GetTempPath()) "$([Guid]::NewGuid()).nupkg"
        [IO.File]::WriteAllBytes($temporaryPackage, $Data)
        $PackagePath = $temporaryPackage
    }

    try {
        $metadata = Get-PSUNuGetPackageMetadata -PackagePath $PackagePath -BaseUrl $BaseUrl
        $catalog = @(Read-PSUNuGetCatalog -Path $Path)
        $existing = $catalog | Where-Object { $_.LowerId -eq $metadata.LowerId -and $_.NormalizedVersion -eq $metadata.NormalizedVersion } | Select-Object -First 1
        if ($existing -and -not $Force) {
            throw [InvalidOperationException]::new("Package '$($metadata.Id)' version '$($metadata.Version)' already exists.")
        }

        $packageDirectory = Join-Path (Join-Path (Join-Path $Path 'v3-flatcontainer') $metadata.LowerId) $metadata.NormalizedVersion
        if (-not (Test-Path $packageDirectory)) {
            New-Item -ItemType Directory -Path $packageDirectory -Force | Out-Null
        }

        $nupkgPath = Join-Path $packageDirectory "$($metadata.LowerId).$($metadata.NormalizedVersion).nupkg"
        $nuspecPath = Join-Path $packageDirectory "$($metadata.LowerId).nuspec"
        Copy-Item -Path $PackagePath -Destination $nupkgPath -Force
        $metadata.NuspecContent | Set-Content -Path $nuspecPath -Encoding utf8

        $packageRecord = [ordered]@{
            Id                       = $metadata.Id
            Version                  = $metadata.Version
            LowerId                  = $metadata.LowerId
            NormalizedVersion        = $metadata.NormalizedVersion
            Listed                   = $true
            Published                = [DateTime]::UtcNow.ToString('o')
            Authors                  = @($metadata.Authors)
            Owners                   = @($metadata.Owners)
            Description              = $metadata.Description
            Summary                  = $metadata.Summary
            Tags                     = @($metadata.Tags)
            Title                    = $metadata.Title
            ProjectUrl               = $metadata.ProjectUrl
            IconUrl                  = $metadata.IconUrl
            LicenseUrl               = $metadata.LicenseUrl
            LicenseExpression        = $metadata.LicenseExpression
            Language                 = $metadata.Language
            MinClientVersion         = $metadata.MinClientVersion
            RequireLicenseAcceptance = [bool]$metadata.RequireLicenseAcceptance
            DependencyGroups         = @($metadata.DependencyGroups)
            PackageTypes             = @($metadata.PackageTypes)
        }

        $catalog = @($catalog | Where-Object { -not ($_.LowerId -eq $metadata.LowerId -and $_.NormalizedVersion -eq $metadata.NormalizedVersion) })
        $catalog += [PSCustomObject]$packageRecord
        Write-PSUNuGetCatalog -Package $catalog -Path $Path
        Update-PSUNuGetStaticMetadata -Path $Path -BaseUrl $BaseUrl

        [PSCustomObject]$packageRecord
    }
    finally {
        if ($temporaryPackage -and (Test-Path $temporaryPackage)) {
            Remove-Item $temporaryPackage -Force
        }
    }
}

function Get-PSUNuGetPackage {
    [CmdletBinding()]
    param(
        [string]$Id,

        [string]$Version,

        [switch]$IncludeUnlisted,

        [string]$Path = (Get-PSUNuGetFeedPath)
    )

    $packages = @(Read-PSUNuGetCatalog -Path $Path)
    if ($Id) {
        $lowerId = $Id.ToLowerInvariant()
        $packages = @($packages | Where-Object { $_.LowerId -eq $lowerId })
    }

    if ($Version) {
        $normalizedVersion = ConvertTo-PSUNuGetNormalizedVersion -Version $Version
        $packages = @($packages | Where-Object { $_.NormalizedVersion -eq $normalizedVersion })
    }

    if (-not $IncludeUnlisted) {
        $packages = @($packages | Where-Object { $_.Listed })
    }

    $packages | Sort-Object LowerId, @{ Expression = { ConvertTo-PSUNuGetVersionSortKey -Version $_.NormalizedVersion } }
}

function Set-PSUNuGetPackageListed {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Id,

        [Parameter(Mandatory)]
        [string]$Version,

        [Parameter(Mandatory)]
        [bool]$Listed,

        [string]$Path = (Get-PSUNuGetFeedPath),

        [string]$BaseUrl = $(if ($env:PSU_NUGET_BASE_URL) { $env:PSU_NUGET_BASE_URL } else { 'http://localhost:5000/nuget' })
    )

    $lowerId = $Id.ToLowerInvariant()
    $normalizedVersion = ConvertTo-PSUNuGetNormalizedVersion -Version $Version
    $catalog = @(Read-PSUNuGetCatalog -Path $Path)
    $package = $catalog | Where-Object { $_.LowerId -eq $lowerId -and $_.NormalizedVersion -eq $normalizedVersion } | Select-Object -First 1
    if (-not $package) {
        throw [System.IO.FileNotFoundException]::new("Package '$Id' version '$Version' was not found.")
    }

    $package.Listed = $Listed
    Write-PSUNuGetCatalog -Package $catalog -Path $Path
    Update-PSUNuGetStaticMetadata -Path $Path -BaseUrl $BaseUrl
    $package
}

function Remove-PSUNuGetPackage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Id,

        [Parameter(Mandatory)]
        [string]$Version,

        [string]$Path = (Get-PSUNuGetFeedPath),

        [string]$BaseUrl = $(if ($env:PSU_NUGET_BASE_URL) { $env:PSU_NUGET_BASE_URL } else { 'http://localhost:5000/nuget' })
    )

    $lowerId = $Id.ToLowerInvariant()
    $normalizedVersion = ConvertTo-PSUNuGetNormalizedVersion -Version $Version
    $catalog = @(Read-PSUNuGetCatalog -Path $Path)
    $package = $catalog | Where-Object { $_.LowerId -eq $lowerId -and $_.NormalizedVersion -eq $normalizedVersion } | Select-Object -First 1
    if (-not $package) {
        throw [System.IO.FileNotFoundException]::new("Package '$Id' version '$Version' was not found.")
    }

    $catalog = @($catalog | Where-Object { -not ($_.LowerId -eq $lowerId -and $_.NormalizedVersion -eq $normalizedVersion) })
    $flatIdDirectory = Join-Path (Join-Path $Path 'v3-flatcontainer') $lowerId
    $packageDirectory = Join-Path $flatIdDirectory $normalizedVersion
    if (Test-Path $packageDirectory) {
        Remove-Item -Path $packageDirectory -Recurse -Force
    }

    if (-not ($catalog | Where-Object { $_.LowerId -eq $lowerId }) -and (Test-Path $flatIdDirectory)) {
        Remove-Item -Path $flatIdDirectory -Recurse -Force
    }

    Write-PSUNuGetCatalog -Package $catalog -Path $Path
    Update-PSUNuGetStaticMetadata -Path $Path -BaseUrl $BaseUrl
    $package
}

function Get-PSUNuGetServiceIndex {
    [CmdletBinding()]
    param(
        [string]$BaseUrl = $(if ($env:PSU_NUGET_BASE_URL) { $env:PSU_NUGET_BASE_URL } else { 'http://localhost:5000/nuget' })
    )

    [ordered]@{
        version   = '3.0.0'
        resources = @(
            [ordered]@{
                '@id'   = (Join-PSUNuGetUrl -BaseUrl $BaseUrl -Segment @('v3-flatcontainer')) + '/'
                '@type' = 'PackageBaseAddress/3.0.0'
            },
            [ordered]@{
                '@id'   = (Join-PSUNuGetUrl -BaseUrl $BaseUrl -Segment @('api/v2/package'))
                '@type' = 'PackagePublish/2.0.0'
            },
            [ordered]@{
                '@id'   = (Join-PSUNuGetUrl -BaseUrl $BaseUrl -Segment @('v3/registration')) + '/'
                '@type' = 'RegistrationsBaseUrl/3.6.0'
            },
            [ordered]@{
                '@id'   = (Join-PSUNuGetUrl -BaseUrl $BaseUrl -Segment @('query'))
                '@type' = 'SearchQueryService/3.5.0'
            },
            [ordered]@{
                '@id'   = (Join-PSUNuGetUrl -BaseUrl $BaseUrl -Segment @('autocomplete'))
                '@type' = 'SearchAutocompleteService/3.5.0'
            }
        )
    }
}

function Search-PSUNuGetPackage {
    [CmdletBinding()]
    param(
        [Alias('q')]
        [string]$Query,

        [int]$Skip = 0,

        [int]$Take = 20,

        [bool]$Prerelease = $false,

        [string]$PackageType,

        [string]$Path = (Get-PSUNuGetFeedPath),

        [string]$BaseUrl = $(if ($env:PSU_NUGET_BASE_URL) { $env:PSU_NUGET_BASE_URL } else { 'http://localhost:5000/nuget' })
    )

    if ($Take -lt 1) { $Take = 20 }
    if ($Take -gt 1000) { $Take = 1000 }
    if ($Skip -lt 0) { $Skip = 0 }

    $packages = @(Get-PSUNuGetPackage -IncludeUnlisted:$false -Path $Path)
    if (-not $Prerelease) {
        $packages = @($packages | Where-Object { -not (Test-PSUNuGetPrereleaseVersion -Version $_.NormalizedVersion) })
    }

    if ($PackageType) {
        $packages = @($packages | Where-Object { @($_.PackageTypes).Name -contains $PackageType })
    }

    if ($Query) {
        $packages = @($packages | Where-Object {
                $_.Id -like "*$Query*" -or
                $_.Title -like "*$Query*" -or
                $_.Description -like "*$Query*" -or
                (@($_.Tags) -join ' ') -like "*$Query*"
            })
    }

    $results = @($packages | Group-Object LowerId | ForEach-Object {
            $packageVersions = @($_.Group | Sort-Object @{ Expression = { ConvertTo-PSUNuGetVersionSortKey -Version $_.NormalizedVersion } })
            $latestPackage = $packageVersions[-1]
            [ordered]@{
                '@id'          = (Join-PSUNuGetUrl -BaseUrl $BaseUrl -Segment @('v3/registration', $latestPackage.LowerId, 'index.json'))
                '@type'        = 'Package'
                registration   = (Join-PSUNuGetUrl -BaseUrl $BaseUrl -Segment @('v3/registration', $latestPackage.LowerId, 'index.json'))
                id             = $latestPackage.Id
                version        = $latestPackage.Version
                description    = $latestPackage.Description
                summary        = $latestPackage.Summary
                title          = $latestPackage.Title
                iconUrl        = $latestPackage.IconUrl
                licenseUrl     = $latestPackage.LicenseUrl
                projectUrl     = $latestPackage.ProjectUrl
                tags           = @($latestPackage.Tags)
                authors        = @($latestPackage.Authors)
                owners         = @($latestPackage.Owners)
                totalDownloads = 0
                verified       = $false
                packageTypes   = @($latestPackage.PackageTypes)
                versions       = @($packageVersions | ForEach-Object {
                        [ordered]@{
                            '@id'     = (Join-PSUNuGetUrl -BaseUrl $BaseUrl -Segment @('v3/registration', $_.LowerId, "$($_.NormalizedVersion).json"))
                            version   = $_.Version
                            downloads = 0
                        }
                    })
            }
        })

    [ordered]@{
        totalHits = $results.Count
        data      = @($results | Select-Object -Skip $Skip -First $Take)
    }
}

function Get-PSUNuGetAutocomplete {
    [CmdletBinding()]
    param(
        [Alias('q')]
        [string]$Query,

        [string]$Id,

        [int]$Skip = 0,

        [int]$Take = 20,

        [bool]$Prerelease = $false,

        [string]$Path = (Get-PSUNuGetFeedPath)
    )

    if ($Take -lt 1) { $Take = 20 }
    if ($Take -gt 1000) { $Take = 1000 }
    if ($Skip -lt 0) { $Skip = 0 }

    $packages = @(Get-PSUNuGetPackage -IncludeUnlisted:$false -Path $Path)
    if (-not $Prerelease) {
        $packages = @($packages | Where-Object { -not (Test-PSUNuGetPrereleaseVersion -Version $_.NormalizedVersion) })
    }

    if ($Id) {
        $lowerId = $Id.ToLowerInvariant()
        return [ordered]@{
            data = @($packages |
                Where-Object { $_.LowerId -eq $lowerId } |
                Sort-Object @{ Expression = { ConvertTo-PSUNuGetVersionSortKey -Version $_.NormalizedVersion } } |
                ForEach-Object { $_.Version })
        }
    }

    $packageIds = @($packages |
        Group-Object LowerId |
        ForEach-Object { $_.Group[0].Id } |
        Where-Object { -not $Query -or $_ -like "*$Query*" } |
        Sort-Object)

    [ordered]@{
        totalHits = $packageIds.Count
        data      = @($packageIds | Select-Object -Skip $Skip -First $Take)
    }
}

Export-ModuleMember -Function @(
    'Get-PSUNuGetFeedPath',
    'Get-PSUNuGetRequestBaseUrl',
    'Test-PSUNuGetSafeSegment',
    'New-PSUNuGetJsonFileResponse',
    'Initialize-PSUNuGetRepository',
    'Publish-PSUNuGetPackage',
    'Get-PSUNuGetPackage',
    'Set-PSUNuGetPackageListed',
    'Remove-PSUNuGetPackage',
    'Update-PSUNuGetStaticMetadata',
    'Get-PSUNuGetServiceIndex',
    'Search-PSUNuGetPackage',
    'Get-PSUNuGetAutocomplete'
)
