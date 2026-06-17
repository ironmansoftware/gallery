$NuGetModulePath = Join-Path $PSScriptRoot '..\PowerShellUniversal.NuGet.psd1'
if (Test-Path $NuGetModulePath) {
    Import-Module $NuGetModulePath -Force
}
else {
    Import-Module PowerShellUniversal.NuGet -Force
}

New-PSUEndpoint -Url '/nuget/v3/index.json' -Description 'Returns the NuGet V3 service index.' -Method @('GET') -Endpoint {
    $serviceIndex = Get-PSUNuGetServiceIndex -BaseUrl (Get-PSUNuGetRequestBaseUrl -Headers $Headers)
    New-PSUApiResponse -StatusCode 200 -ContentType 'application/json' -Body ($serviceIndex | ConvertTo-Json -Depth 50)
}

New-PSUEndpoint -Url '/nuget/query' -Description 'Searches NuGet packages.' -Method @('GET') -Endpoint {
    param(
        $q,
        [int]$skip = 0,
        [int]$take = 20,
        [bool]$prerelease = $false,
        $packageType
    )

    $searchResult = Search-PSUNuGetPackage -Query $q -Skip $skip -Take $take -Prerelease $prerelease -PackageType $packageType -BaseUrl (Get-PSUNuGetRequestBaseUrl -Headers $Headers)
    New-PSUApiResponse -StatusCode 200 -ContentType 'application/json' -Body ($searchResult | ConvertTo-Json -Depth 50)
}

New-PSUEndpoint -Url '/nuget/autocomplete' -Description 'Returns NuGet package ID and version autocomplete results.' -Method @('GET') -Endpoint {
    param(
        $q,
        $id,
        [int]$skip = 0,
        [int]$take = 20,
        [bool]$prerelease = $false
    )

    $autocompleteResult = Get-PSUNuGetAutocomplete -Query $q -Id $id -Skip $skip -Take $take -Prerelease $prerelease
    New-PSUApiResponse -StatusCode 200 -ContentType 'application/json' -Body ($autocompleteResult | ConvertTo-Json -Depth 50)
}

New-PSUEndpoint -Url '/nuget/v3-flatcontainer/:id/index.json' -Description 'Returns the NuGet flat container version index.' -Method @('GET') -Endpoint {
    param($id)

    if (-not (Test-PSUNuGetSafeSegment -Value $id)) {
        return New-PSUApiResponse -StatusCode 400 -Body 'The package ID is invalid.'
    }

    $indexPath = Join-Path (Join-Path (Join-Path (Get-PSUNuGetFeedPath) 'v3-flatcontainer') $id.ToLowerInvariant()) 'index.json'
    New-PSUNuGetJsonFileResponse -Path $indexPath
}

New-PSUEndpoint -Url '/nuget/v3-flatcontainer/:id/:fileName' -Description 'Returns a NuGet flat container metadata file.' -Method @('GET') -Endpoint {
    param($id, $fileName)

    if (-not (Test-PSUNuGetSafeSegment -Value $id) -or -not [string]::Equals($fileName, 'index.json', [StringComparison]::OrdinalIgnoreCase)) {
        return New-PSUApiResponse -StatusCode 400 -Body 'The flat container path is invalid.'
    }

    $indexPath = Join-Path (Join-Path (Join-Path (Get-PSUNuGetFeedPath) 'v3-flatcontainer') $id.ToLowerInvariant()) 'index.json'
    New-PSUNuGetJsonFileResponse -Path $indexPath
}

New-PSUEndpoint -Url '/nuget/v3-flatcontainer/:id/:version/:fileName' -Description 'Returns NuGet package content or manifest data from the flat container.' -Method @('GET') -Endpoint {
    param($id, $version, $fileName)

    if (-not (Test-PSUNuGetSafeSegment -Value $id) -or -not (Test-PSUNuGetSafeSegment -Value $version) -or -not (Test-PSUNuGetSafeSegment -Value $fileName)) {
        return New-PSUApiResponse -StatusCode 400 -Body 'The package path is invalid.'
    }

    try {
        $package = Get-PSUNuGetPackage -Id $id -Version $version -IncludeUnlisted | Select-Object -First 1
    }
    catch [System.ArgumentException] {
        return New-PSUApiResponse -StatusCode 400 -Body $_.Exception.Message
    }

    if (-not $package) {
        return New-PSUApiResponse -StatusCode 404 -Body "Package '$id' version '$version' was not found."
    }

    $expectedPackageFileName = "$($package.LowerId).$($package.NormalizedVersion).nupkg"
    $expectedNuspecFileName = "$($package.LowerId).nuspec"
    if (-not [string]::Equals($fileName, $expectedPackageFileName, [StringComparison]::OrdinalIgnoreCase) -and
        -not [string]::Equals($fileName, $expectedNuspecFileName, [StringComparison]::OrdinalIgnoreCase)) {
        return New-PSUApiResponse -StatusCode 404 -Body 'The requested package file was not found.'
    }

    $resolvedFileName = if ([string]::Equals($fileName, $expectedNuspecFileName, [StringComparison]::OrdinalIgnoreCase)) { $expectedNuspecFileName } else { $expectedPackageFileName }
    $packagePath = Join-Path (Join-Path (Join-Path (Join-Path (Get-PSUNuGetFeedPath) 'v3-flatcontainer') $package.LowerId) $package.NormalizedVersion) $resolvedFileName
    if (-not (Test-Path $packagePath)) {
        return New-PSUApiResponse -StatusCode 404 -Body 'The requested package file was not found.'
    }

    if ([string]::Equals($resolvedFileName, $expectedNuspecFileName, [StringComparison]::OrdinalIgnoreCase)) {
        return New-PSUApiResponse -StatusCode 200 -ContentType 'application/xml' -Body (Get-Content -Path $packagePath -Raw)
    }

    New-PSUApiResponse -StatusCode 200 -ContentType 'application/octet-stream' -Data ([IO.File]::ReadAllBytes($packagePath))
}

New-PSUEndpoint -Url '/nuget/v3/registration/:id/index.json' -Description 'Returns the NuGet registration index.' -Method @('GET') -Endpoint {
    param($id)

    if (-not (Test-PSUNuGetSafeSegment -Value $id)) {
        return New-PSUApiResponse -StatusCode 400 -Body 'The package ID is invalid.'
    }

    $indexPath = Join-Path (Join-Path (Join-Path (Get-PSUNuGetFeedPath) 'v3\registration') $id.ToLowerInvariant()) 'index.json'
    New-PSUNuGetJsonFileResponse -Path $indexPath
}

New-PSUEndpoint -Url '/nuget/v3/registration/:id/:leaf' -Description 'Returns a NuGet registration leaf.' -Method @('GET') -Endpoint {
    param($id, $leaf)

    if (-not (Test-PSUNuGetSafeSegment -Value $id) -or -not (Test-PSUNuGetSafeSegment -Value $leaf) -or -not $leaf.EndsWith('.json', [StringComparison]::OrdinalIgnoreCase)) {
        return New-PSUApiResponse -StatusCode 400 -Body 'The registration path is invalid.'
    }

    $leafPath = Join-Path (Join-Path (Join-Path (Get-PSUNuGetFeedPath) 'v3\registration') $id.ToLowerInvariant()) $leaf.ToLowerInvariant()
    New-PSUNuGetJsonFileResponse -Path $leafPath
}

New-PSUEndpoint -Url '/nuget/api/v2/package' -Description 'Publishes a NuGet package from raw .nupkg request bytes.' -Method @('PUT', 'POST') -Endpoint {
    try {
        $package = Publish-PSUNuGetPackage -Data $Data -BaseUrl (Get-PSUNuGetRequestBaseUrl -Headers $Headers)
        New-PSUApiResponse -StatusCode 201 -ContentType 'application/json' -Body ($package | ConvertTo-Json -Depth 50)
    }
    catch [System.InvalidOperationException] {
        New-PSUApiResponse -StatusCode 409 -Body $_.Exception.Message
    }
    catch [System.ArgumentException] {
        New-PSUApiResponse -StatusCode 400 -Body $_.Exception.Message
    }
} -Authentication -Role @('Administrator', 'NuGet Publisher')

New-PSUEndpoint -Url '/nuget/api/v2/package/:id/:version' -Description 'Unlists or relists a NuGet package.' -Method @('DELETE', 'POST') -Endpoint {
    param($id, $version)

    try {
        if ($Method -eq 'DELETE') {
            Set-PSUNuGetPackageListed -Id $id -Version $version -Listed $false -BaseUrl (Get-PSUNuGetRequestBaseUrl -Headers $Headers) | Out-Null
            New-PSUApiResponse -StatusCode 204
        }
        else {
            $package = Set-PSUNuGetPackageListed -Id $id -Version $version -Listed $true -BaseUrl (Get-PSUNuGetRequestBaseUrl -Headers $Headers)
            New-PSUApiResponse -StatusCode 200 -ContentType 'application/json' -Body ($package | ConvertTo-Json -Depth 50)
        }
    }
    catch [System.IO.FileNotFoundException] {
        New-PSUApiResponse -StatusCode 404 -Body $_.Exception.Message
    }
} -Authentication -Role @('Administrator', 'NuGet Publisher')

New-PSUEndpoint -Url '/nuget/package' -Description 'Lists packages in the NuGet feed catalog.' -Method @('GET') -Endpoint {
    param($id, $version, [bool]$includeUnlisted = $false)

    $packages = Get-PSUNuGetPackage -Id $id -Version $version -IncludeUnlisted:$includeUnlisted
    New-PSUApiResponse -StatusCode 200 -ContentType 'application/json' -Body ($packages | ConvertTo-Json -Depth 50)
} -Authentication -Role @('Administrator', 'NuGet Publisher')

New-PSUEndpoint -Url '/nuget/package/:id/:version' -Description 'Deletes a package from the NuGet feed catalog and static package store.' -Method @('DELETE') -Endpoint {
    param($id, $version)

    try {
        Remove-PSUNuGetPackage -Id $id -Version $version -BaseUrl (Get-PSUNuGetRequestBaseUrl -Headers $Headers) | Out-Null
        New-PSUApiResponse -StatusCode 204
    }
    catch [System.IO.FileNotFoundException] {
        New-PSUApiResponse -StatusCode 404 -Body $_.Exception.Message
    }
} -Authentication -Role @('Administrator', 'NuGet Publisher')