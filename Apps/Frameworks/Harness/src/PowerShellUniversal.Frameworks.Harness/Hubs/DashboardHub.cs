using Microsoft.AspNetCore.SignalR;
using PowerShellUniversal.Frameworks.Harness.Models;
using PowerShellUniversal.Frameworks.Harness.Services;

namespace PowerShellUniversal.Frameworks.Harness.Hubs;

public sealed class DashboardHub(
    HarnessDefinitionProvider definitionProvider,
    HarnessEndpointRegistry endpointRegistry,
    HarnessPowerShellService powerShellService,
    HarnessRealtimeService realtimeService,
    HarnessObjectNormalizer normalizer,
    ILogger<DashboardHub> logger) : Hub
{
    public override async Task OnConnectedAsync()
    {
        var httpContext = Context.GetHttpContext();
        var dashboardId = httpContext?.Request.Query["dashboardid"].ToString() ?? string.Empty;
        var sessionId = httpContext?.Request.Query["sessionid"].ToString() ?? string.Empty;
        var pageId = httpContext?.Request.Query["pageid"].ToString() ?? string.Empty;
        var timezone = httpContext?.Request.Query["timezone"].ToString();

        realtimeService.RegisterConnection(new HarnessConnection(
            ConnectionId: Context.ConnectionId,
            DashboardId: dashboardId,
            SessionId: sessionId,
            PageId: pageId,
            Timezone: timezone,
            ConnectedAt: DateTimeOffset.UtcNow));

        if (!string.IsNullOrWhiteSpace(dashboardId))
        {
            await Groups.AddToGroupAsync(Context.ConnectionId, dashboardId);
        }

        await base.OnConnectedAsync();
    }

    public override async Task OnDisconnectedAsync(Exception? exception)
    {
        realtimeService.RemoveConnection(Context.ConnectionId);
        await base.OnDisconnectedAsync(exception);
    }

    public async Task Event(HarnessClientEvent item)
    {
        await ExecuteClientEventAsync(item);
    }

    public async Task ClientEvent(string eventId, string eventName, string? eventData, string? location)
    {
        await ExecuteClientEventAsync(new HarnessClientEvent
        {
            EventId = eventId,
            EventName = eventName,
            EventData = eventData,
            Location = location
        });
    }

    public Task GetState(string requestId, string state)
    {
        realtimeService.StoreSessionState(requestId, state);
        return Task.CompletedTask;
    }

    public Task WriteLog(HarnessLogMessage message)
    {
        logger.LogInformation("Harness client log: {Level} {Message}", message.Level, message.Message);
        return Task.CompletedTask;
    }

    private async Task ExecuteClientEventAsync(HarnessClientEvent item)
    {
        var definition = definitionProvider.GetDefinition();
        var endpointId = string.IsNullOrWhiteSpace(item.EventId) ? item.EventName : item.EventId;
        if (!definition.TryResolveEndpointScript(endpointId, out var scriptPath)
            && !endpointRegistry.TryResolveEndpointScript(endpointId, out scriptPath))
        {
            logger.LogWarning("No websocket endpoint script was configured for {EndpointId}", endpointId);
            return;
        }

        var httpContext = Context.GetHttpContext();
        var invocationContext = new HarnessInvocationContext
        {
            DashboardId = httpContext?.Request.Query["dashboardid"].ToString() ?? string.Empty,
            SessionId = httpContext?.Request.Query["sessionid"].ToString() ?? string.Empty,
            PageId = httpContext?.Request.Query["pageid"].ToString() ?? string.Empty,
            ConnectionId = Context.ConnectionId,
            EndpointId = endpointId,
            EventName = item.EventName,
            EventData = normalizer.NormalizeForJson(item.EventData),
            Location = item.Location,
            Method = "WEBSOCKET",
            Query = httpContext?.Request.Query.ToDictionary(
                pair => pair.Key,
                pair => pair.Value.Count == 1 ? (object?)pair.Value[0] : pair.Value.ToArray(),
                StringComparer.OrdinalIgnoreCase)
                ?? new Dictionary<string, object?>(StringComparer.OrdinalIgnoreCase),
            Headers = httpContext?.Request.Headers.ToDictionary(
                pair => pair.Key,
                pair => (string?)pair.Value.FirstOrDefault(),
                StringComparer.OrdinalIgnoreCase)
                ?? new Dictionary<string, string?>(StringComparer.OrdinalIgnoreCase),
            Cookies = httpContext?.Request.Cookies.ToDictionary(
                pair => pair.Key,
                pair => (string?)pair.Value,
                StringComparer.OrdinalIgnoreCase)
                ?? new Dictionary<string, string?>(StringComparer.OrdinalIgnoreCase),
            Form = new Dictionary<string, object?>(StringComparer.OrdinalIgnoreCase),
            Body = null,
            JsonBody = normalizer.NormalizeForJson(item.EventData),
            Files = Array.Empty<HarnessUploadedFile>()
        };

        await powerShellService.InvokeEndpointAsync(scriptPath, invocationContext);
    }
}
