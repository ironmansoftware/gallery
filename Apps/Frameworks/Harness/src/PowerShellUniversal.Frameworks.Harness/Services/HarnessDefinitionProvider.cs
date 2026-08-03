using System.Management.Automation;
using Microsoft.Extensions.Options;
using PowerShellUniversal.Frameworks.Harness.Models;

namespace PowerShellUniversal.Frameworks.Harness.Services;

public sealed class HarnessDefinitionProvider(
    IOptions<HarnessOptions> options,
    IHostEnvironment hostEnvironment,
    HarnessObjectNormalizer normalizer,
    ILogger<HarnessDefinitionProvider> logger)
{
    private readonly object _syncLock = new();
    private HarnessDefinition? _cachedDefinition;
    private DateTime _cachedWriteTimeUtc;

    public HarnessDefinition GetDefinition()
    {
        var definitionPath = ResolvePath(hostEnvironment.ContentRootPath, options.Value.DefinitionPath);
        var writeTimeUtc = File.GetLastWriteTimeUtc(definitionPath);

        lock (_syncLock)
        {
            if (_cachedDefinition is not null && writeTimeUtc == _cachedWriteTimeUtc)
            {
                return _cachedDefinition;
            }

            _cachedDefinition = LoadDefinition(definitionPath);
            _cachedWriteTimeUtc = writeTimeUtc;
            return _cachedDefinition;
        }
    }

    private HarnessDefinition LoadDefinition(string definitionPath)
    {
        if (!File.Exists(definitionPath))
        {
            throw new FileNotFoundException($"Harness definition script was not found: {definitionPath}", definitionPath);
        }

        logger.LogInformation("Loading harness definition from {DefinitionPath}", definitionPath);

        using var powershell = PowerShell.Create();
        var definitionScript = File.ReadAllText(definitionPath);
        var definitionDirectory = Path.GetDirectoryName(definitionPath) ?? hostEnvironment.ContentRootPath;
        powershell.Runspace.SessionStateProxy.SetVariable("PSScriptRoot", definitionDirectory);
        powershell.Runspace.SessionStateProxy.SetVariable("PSCommandPath", definitionPath);
        powershell.Runspace.SessionStateProxy.SetVariable("HarnessScriptRoot", definitionDirectory);
        powershell.Runspace.SessionStateProxy.SetVariable("HarnessScriptPath", definitionPath);
        powershell.AddScript($"Set-Location -LiteralPath '{definitionDirectory.Replace("'", "''")}'", useLocalScope: false);
        powershell.AddScript(definitionScript, useLocalScope: false);
        var results = powershell.Invoke();

        if (powershell.HadErrors)
        {
            var errorText = string.Join(Environment.NewLine, powershell.Streams.Error.Select(error => error.ToString()));
            throw new InvalidOperationException($"Failed to load harness definition.{Environment.NewLine}{errorText}");
        }

        var normalized = normalizer.NormalizeForJson(results.Count switch
        {
            0 => null,
            1 => results[0],
            _ => results
        });

        if (normalized is not IReadOnlyDictionary<string, object?> root)
        {
            throw new InvalidOperationException("Harness definition script must return a hashtable-like object.");
        }

        var dashboardScriptPath = GetOptionalPath(root, definitionDirectory, "DashboardScript", "Dashboard");
        var endpointRootPath = GetOptionalPath(root, definitionDirectory, "EndpointRoot");
        var endpointScripts = GetDictionary(root, "Endpoints")
            .ToDictionary(
                pair => pair.Key,
                pair => ResolvePath(definitionDirectory, Convert.ToString(pair.Value) ?? string.Empty),
                StringComparer.OrdinalIgnoreCase);

        var staticAssets = GetArray(root, "StaticAssets")
            .OfType<IReadOnlyDictionary<string, object?>>()
            .Select(asset => new HarnessStaticAsset(
                RequestPath: Convert.ToString(asset.GetValueOrDefault("RequestPath")) ?? string.Empty,
                PhysicalPath: ResolvePath(definitionDirectory, Convert.ToString(asset.GetValueOrDefault("Path")) ?? string.Empty)))
            .Where(asset => !string.IsNullOrWhiteSpace(asset.RequestPath) && !string.IsNullOrWhiteSpace(asset.PhysicalPath))
            .ToArray();

        var shell = GetDictionary(root, "Shell");
        var shellDefinition = new HarnessShellDefinition(
            Title: Convert.ToString(shell.GetValueOrDefault("Title")) ?? "PSU Framework Harness",
            MountId: Convert.ToString(shell.GetValueOrDefault("MountId")) ?? "root",
            Scripts: GetStringArray(shell, "Scripts"),
            Styles: GetStringArray(shell, "Styles"));

        return new HarnessDefinition(
            SourcePath: definitionPath,
            DashboardScriptPath: dashboardScriptPath,
            EndpointRootPath: endpointRootPath,
            EndpointScripts: endpointScripts,
            StaticAssets: staticAssets,
            Shell: shellDefinition);
    }

    private static IReadOnlyDictionary<string, object?> GetDictionary(IReadOnlyDictionary<string, object?> source, params string[] keys)
    {
        foreach (var key in keys)
        {
            if (source.TryGetValue(key, out var value) && value is IReadOnlyDictionary<string, object?> dictionary)
            {
                return dictionary;
            }
        }

        return new Dictionary<string, object?>(StringComparer.OrdinalIgnoreCase);
    }

    private static IReadOnlyList<object?> GetArray(IReadOnlyDictionary<string, object?> source, params string[] keys)
    {
        foreach (var key in keys)
        {
            if (!source.TryGetValue(key, out var value) || value is null)
            {
                continue;
            }

            if (value is IReadOnlyList<object?> list)
            {
                return list;
            }

            if (value is IEnumerable<object?> enumerable)
            {
                return enumerable.ToArray();
            }

            return new[] { value };
        }

        return Array.Empty<object?>();
    }

    private static IReadOnlyList<string> GetStringArray(IReadOnlyDictionary<string, object?> source, params string[] keys)
    {
        return GetArray(source, keys)
            .Select(item => Convert.ToString(item))
            .Where(item => !string.IsNullOrWhiteSpace(item))
            .Cast<string>()
            .ToArray();
    }

    private static string? GetOptionalPath(IReadOnlyDictionary<string, object?> source, string basePath, params string[] keys)
    {
        foreach (var key in keys)
        {
            if (!source.TryGetValue(key, out var value))
            {
                continue;
            }

            var stringValue = Convert.ToString(value);
            if (!string.IsNullOrWhiteSpace(stringValue))
            {
                return ResolvePath(basePath, stringValue);
            }
        }

        return null;
    }

    private static string ResolvePath(string basePath, string value)
    {
        if (Path.IsPathRooted(value))
        {
            return Path.GetFullPath(value);
        }

        return Path.GetFullPath(Path.Combine(basePath, value));
    }
}
