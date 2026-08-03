using System.Collections.Concurrent;
using System.Security.Cryptography;
using System.Text;

namespace PowerShellUniversal.Frameworks.Harness.Services;

public sealed class HarnessEndpointRegistry
{
    private readonly ConcurrentDictionary<string, string> scriptPaths = new(StringComparer.OrdinalIgnoreCase);
    private readonly string endpointRoot = Path.Combine(
        Path.GetTempPath(),
        "psu-framework-harness",
        "inline-endpoints",
        Guid.NewGuid().ToString("n"));

    public string RegisterEndpoint(string componentId, string scriptContent, IEnumerable<string>? modulePaths)
    {
        if (string.IsNullOrWhiteSpace(scriptContent))
        {
            throw new ArgumentException("Inline endpoint script content cannot be empty.", nameof(scriptContent));
        }

        Directory.CreateDirectory(endpointRoot);

        var endpointId = $"{SanitizeComponentId(componentId)}-{Convert.ToHexString(RandomNumberGenerator.GetBytes(6)).ToLowerInvariant()}";
        var scriptPath = Path.Combine(endpointRoot, endpointId + ".ps1");

        var builder = new StringBuilder();
        foreach (var modulePath in (modulePaths ?? Array.Empty<string>())
            .Where(path => !string.IsNullOrWhiteSpace(path))
            .Distinct(StringComparer.OrdinalIgnoreCase))
        {
            builder.Append("Import-Module -Name '");
            builder.Append(modulePath.Replace("'", "''"));
            builder.AppendLine("' -Force");
        }

        builder.AppendLine();
        builder.AppendLine(scriptContent);

        File.WriteAllText(scriptPath, builder.ToString(), new UTF8Encoding(encoderShouldEmitUTF8Identifier: false));
        scriptPaths[endpointId] = scriptPath;
        return endpointId;
    }

    public bool TryResolveEndpointScript(string endpointId, out string scriptPath)
    {
        return scriptPaths.TryGetValue(endpointId, out scriptPath!);
    }

    private static string SanitizeComponentId(string componentId)
    {
        if (string.IsNullOrWhiteSpace(componentId))
        {
            return "endpoint";
        }

        var characters = componentId
            .Select(character => char.IsLetterOrDigit(character) ? char.ToLowerInvariant(character) : '-')
            .ToArray();

        return new string(characters).Trim('-');
    }
}