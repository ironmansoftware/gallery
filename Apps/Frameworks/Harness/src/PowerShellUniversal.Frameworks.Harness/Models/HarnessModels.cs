namespace PowerShellUniversal.Frameworks.Harness.Models;

public sealed class HarnessOptions
{
    public string DefinitionPath { get; set; } = "../../sample/harness.ps1";

    public string DashboardId { get; set; } = "harness-dashboard";

    public string PageId { get; set; } = "home";

    public string SessionCookieName { get; set; } = "psu-harness-session-id";
}

public sealed record HarnessStaticAsset(string RequestPath, string PhysicalPath);

public sealed record HarnessShellDefinition(
    string Title,
    string MountId,
    IReadOnlyList<string> Scripts,
    IReadOnlyList<string> Styles);

public sealed record HarnessDefinition(
    string SourcePath,
    string? DashboardScriptPath,
    string? EndpointRootPath,
    IReadOnlyDictionary<string, string> EndpointScripts,
    IReadOnlyList<HarnessStaticAsset> StaticAssets,
    HarnessShellDefinition Shell)
{
    public bool TryResolveEndpointScript(string endpointId, out string scriptPath)
    {
        if (EndpointScripts.TryGetValue(endpointId, out var configuredScript) && !string.IsNullOrWhiteSpace(configuredScript))
        {
            scriptPath = configuredScript;
            return true;
        }

        if (!string.IsNullOrWhiteSpace(EndpointRootPath))
        {
            var candidate = Path.Combine(EndpointRootPath, endpointId + ".ps1");
            if (File.Exists(candidate))
            {
                scriptPath = candidate;
                return true;
            }
        }

        scriptPath = string.Empty;
        return false;
    }
}

public sealed class HarnessInvocationContext
{
    public required string DashboardId { get; init; }

    public required string SessionId { get; init; }

    public required string PageId { get; init; }

    public string? ConnectionId { get; init; }

    public string? EndpointId { get; init; }

    public string? EventName { get; init; }

    public object? EventData { get; init; }

    public string? Location { get; init; }

    public required string Method { get; init; }

    public required IReadOnlyDictionary<string, object?> Query { get; init; }

    public required IReadOnlyDictionary<string, string?> Headers { get; init; }

    public required IReadOnlyDictionary<string, string?> Cookies { get; init; }

    public required IReadOnlyDictionary<string, object?> Form { get; init; }

    public string? Body { get; init; }

    public object? JsonBody { get; init; }

    public required IReadOnlyList<HarnessUploadedFile> Files { get; init; }
}

public sealed record HarnessUploadedFile(
    string Name,
    string FileName,
    string ContentType,
    long Length,
    string TempPath);

public sealed record HarnessConnection(
    string ConnectionId,
    string DashboardId,
    string SessionId,
    string PageId,
    string? Timezone,
    DateTimeOffset ConnectedAt);

public sealed record HarnessDownload(
    string Id,
    string FileName,
    string ContentType,
    byte[] Content);

public sealed class HarnessClientEvent
{
    public string? Type { get; init; }

    public string EventId { get; init; } = string.Empty;

    public string EventName { get; init; } = string.Empty;

    public object? EventData { get; init; }

    public string? Location { get; init; }
}

public sealed class HarnessLogMessage
{
    public string? Scope { get; init; }

    public string? Feature { get; init; }

    public string? Message { get; init; }

    public string? Level { get; init; }
}

public sealed class HarnessMessageRequest
{
    public string MessageType { get; init; } = string.Empty;

    public object? Data { get; init; }

    public string? ConnectionId { get; init; }

    public string? DashboardId { get; init; }
}

public sealed class HarnessDownloadRegistrationRequest
{
    public string FileName { get; init; } = string.Empty;

    public string Content { get; init; } = string.Empty;

    public string ContentType { get; init; } = "text/plain";
}
