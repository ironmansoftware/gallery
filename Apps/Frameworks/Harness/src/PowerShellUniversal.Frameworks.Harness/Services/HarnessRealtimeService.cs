using System.Collections.Concurrent;
using Microsoft.AspNetCore.SignalR;
using PowerShellUniversal.Frameworks.Harness.Hubs;
using PowerShellUniversal.Frameworks.Harness.Models;

namespace PowerShellUniversal.Frameworks.Harness.Services;

public sealed class HarnessRealtimeService(
    IHubContext<DashboardHub> hubContext,
    HarnessObjectNormalizer normalizer)
{
    private readonly ConcurrentDictionary<string, HarnessConnection> _connections = new(StringComparer.OrdinalIgnoreCase);
    private readonly ConcurrentDictionary<string, object?> _sessionState = new(StringComparer.OrdinalIgnoreCase);
    private readonly ConcurrentDictionary<string, HarnessDownload> _downloads = new(StringComparer.OrdinalIgnoreCase);

    public void RegisterConnection(HarnessConnection connection)
    {
        _connections[connection.ConnectionId] = connection;
    }

    public void RemoveConnection(string connectionId)
    {
        _connections.TryRemove(connectionId, out _);
    }

    public IReadOnlyList<HarnessConnection> GetConnections()
    {
        return _connections.Values
            .OrderBy(connection => connection.ConnectedAt)
            .ToArray();
    }

    public async Task SendAsync(string messageType, object? data = null, string? connectionId = null, string? dashboardId = null)
    {
        var clientProxy = !string.IsNullOrWhiteSpace(connectionId)
            ? hubContext.Clients.Client(connectionId)
            : !string.IsNullOrWhiteSpace(dashboardId)
                ? hubContext.Clients.Group(dashboardId)
                : hubContext.Clients.All;

        if (data is null)
        {
            await clientProxy.SendAsync(messageType);
            return;
        }

        await clientProxy.SendAsync(messageType, normalizer.NormalizeForJson(data));
    }

    public void StoreSessionState(string requestId, object? state)
    {
        _sessionState[requestId] = normalizer.NormalizeForJson(state);
    }

    public bool TryGetSessionState(string requestId, out object? state)
    {
        return _sessionState.TryGetValue(requestId, out state);
    }

    public void StoreDownload(HarnessDownload download)
    {
        _downloads[download.Id] = download;
    }

    public bool TryGetDownload(string id, out HarnessDownload? download)
    {
        var found = _downloads.TryGetValue(id, out var value);
        download = value;
        return found;
    }
}
