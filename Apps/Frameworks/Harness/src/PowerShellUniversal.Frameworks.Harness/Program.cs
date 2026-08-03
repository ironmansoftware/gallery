using System.Net;
using System.Text;
using Microsoft.AspNetCore.Http.Features;
using Microsoft.Extensions.FileProviders;
using Microsoft.Extensions.Options;
using PowerShellUniversal.Frameworks.Harness.Hubs;
using PowerShellUniversal.Frameworks.Harness.Models;
using PowerShellUniversal.Frameworks.Harness.Services;

var builder = WebApplication.CreateBuilder(args);

builder.Services.Configure<HarnessOptions>(builder.Configuration.GetSection("Harness"));
builder.Services.AddSignalR().AddJsonProtocol(options =>
{
    options.PayloadSerializerOptions.PropertyNamingPolicy = null;
});
builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(policy =>
        policy
            .SetIsOriginAllowed(_ => true)
            .AllowAnyHeader()
            .AllowAnyMethod()
            .AllowCredentials());
});
builder.Services.AddSingleton<HarnessObjectNormalizer>();
builder.Services.AddSingleton<HarnessDefinitionProvider>();
builder.Services.AddSingleton<HarnessEndpointRegistry>();
builder.Services.AddSingleton<HarnessRealtimeService>();
builder.Services.AddSingleton<HarnessPowerShellService>();

var app = builder.Build();

app.UseCors();

var definitionProvider = app.Services.GetRequiredService<HarnessDefinitionProvider>();
var initialDefinition = definitionProvider.GetDefinition();
foreach (var staticAsset in initialDefinition.StaticAssets)
{
    if (!Directory.Exists(staticAsset.PhysicalPath))
    {
        app.Logger.LogWarning("Static asset path does not exist: {PhysicalPath}", staticAsset.PhysicalPath);
        continue;
    }

    app.UseStaticFiles(new StaticFileOptions
    {
        FileProvider = new PhysicalFileProvider(staticAsset.PhysicalPath),
        RequestPath = staticAsset.RequestPath
    });
}

app.MapGet("/", (HttpContext httpContext, HarnessDefinitionProvider provider, IOptions<HarnessOptions> options) =>
{
    var definition = provider.GetDefinition();
    var html = RenderShellPage(httpContext, definition, options.Value);
    return Results.Content(html, "text/html", Encoding.UTF8);
});

app.MapGet("/api/internal/dashboard", async (
    HttpContext httpContext,
    HarnessDefinitionProvider provider,
    HarnessPowerShellService powerShellService,
    IOptions<HarnessOptions> options) =>
{
    var definition = provider.GetDefinition();
    if (string.IsNullOrWhiteSpace(definition.DashboardScriptPath))
    {
        return Results.Json(new
        {
            dashboard = new { type = "empty" },
            sessionId = GetOrCreateSessionId(httpContext, options.Value),
            pageId = options.Value.PageId,
            dashboardName = "PSU Framework Harness",
            developerLicense = true
        });
    }

    var context = await CreateInvocationContextAsync(httpContext, options.Value, endpointId: null, methodOverride: "GET /api/internal/dashboard");
    var bootstrap = await powerShellService.InvokeBootstrapAsync(definition.DashboardScriptPath, context);
    return Results.Json(bootstrap);
});

app.MapMethods("/api/internal/component/element/{id}", new[] { "GET", "POST" }, async (
    HttpContext httpContext,
    string id,
    HarnessDefinitionProvider provider,
    HarnessEndpointRegistry endpointRegistry,
    HarnessPowerShellService powerShellService,
    IOptions<HarnessOptions> options) =>
{
    var definition = provider.GetDefinition();
    if (!definition.TryResolveEndpointScript(id, out var scriptPath)
        && !endpointRegistry.TryResolveEndpointScript(id, out scriptPath))
    {
        return Results.Json(new { });
    }

    var context = await CreateInvocationContextAsync(httpContext, options.Value, endpointId: id);
    var result = await powerShellService.InvokeEndpointAsync(scriptPath, context);
    return ToEndpointResult(httpContext, result);
});

app.MapPost("/api/internal/component/element/sessionState/{requestId}", async (
    HttpContext httpContext,
    string requestId,
    HarnessRealtimeService realtimeService,
    HarnessObjectNormalizer normalizer) =>
{
    using var reader = new StreamReader(httpContext.Request.Body);
    var body = await reader.ReadToEndAsync();
    if (normalizer.TryParseJson(body, out var jsonBody))
    {
        realtimeService.StoreSessionState(requestId, jsonBody);
    }
    else
    {
        realtimeService.StoreSessionState(requestId, body);
    }

    return Results.Json(new { message = "Session state set" });
});

app.MapGet("/api/internal/dashboard/download/{dashboardId}/{id}", (
    string id,
    HarnessRealtimeService realtimeService) =>
{
    if (!realtimeService.TryGetDownload(id, out var download) || download is null)
    {
        return Results.NotFound();
    }

    return Results.File(download.Content, download.ContentType, download.FileName);
});

app.MapGet("/api/harness/connections", (HarnessRealtimeService realtimeService) =>
    Results.Json(realtimeService.GetConnections()));

app.MapPost("/api/harness/messages", async (
    HarnessMessageRequest request,
    HarnessRealtimeService realtimeService,
    IOptions<HarnessOptions> options) =>
{
    await realtimeService.SendAsync(
        request.MessageType,
        request.Data,
        request.ConnectionId,
        string.IsNullOrWhiteSpace(request.DashboardId) ? options.Value.DashboardId : request.DashboardId);

    return Results.Json(new { message = "Message sent" });
});

app.MapPost("/api/harness/downloads/{id}", (
    string id,
    HarnessDownloadRegistrationRequest request,
    HarnessRealtimeService realtimeService) =>
{
    realtimeService.StoreDownload(new HarnessDownload(
        Id: id,
        FileName: request.FileName,
        ContentType: request.ContentType,
        Content: Encoding.UTF8.GetBytes(request.Content)));

    return Results.Json(new { message = "Download stored" });
});

app.MapHub<DashboardHub>("/dashboardhub");

app.Run();

static IResult ToEndpointResult(HttpContext httpContext, object? result)
{
    if (result is string text && WantsPlainText(httpContext))
    {
        return Results.Text(text, "text/plain", Encoding.UTF8);
    }

    return Results.Json(result ?? new { });
}

static bool WantsPlainText(HttpContext httpContext)
{
    var accept = httpContext.Request.Headers.Accept.ToString();
    return accept.Contains("text/plain", StringComparison.OrdinalIgnoreCase);
}

static string GetOrCreateSessionId(HttpContext httpContext, HarnessOptions options)
{
    if (httpContext.Request.Cookies.TryGetValue(options.SessionCookieName, out var existing) && !string.IsNullOrWhiteSpace(existing))
    {
        return existing;
    }

    var sessionId = Guid.NewGuid().ToString();
    httpContext.Response.Cookies.Append(options.SessionCookieName, sessionId, new CookieOptions
    {
        HttpOnly = true,
        SameSite = SameSiteMode.Lax,
        IsEssential = true
    });
    return sessionId;
}

static async Task<HarnessInvocationContext> CreateInvocationContextAsync(
    HttpContext httpContext,
    HarnessOptions options,
    string? endpointId,
    string? methodOverride = null)
{
    var normalizer = httpContext.RequestServices.GetRequiredService<HarnessObjectNormalizer>();
    var sessionId = GetOrCreateSessionId(httpContext, options);

    var query = new Dictionary<string, object?>(StringComparer.OrdinalIgnoreCase);
    foreach (var pair in httpContext.Request.Query)
    {
        query[pair.Key] = pair.Value.Count == 1 ? pair.Value[0] : pair.Value.ToArray();
    }

    var headers = httpContext.Request.Headers.ToDictionary(
        pair => pair.Key,
        pair => (string?)pair.Value.FirstOrDefault(),
        StringComparer.OrdinalIgnoreCase);

    var cookies = httpContext.Request.Cookies.ToDictionary(
        pair => pair.Key,
        pair => (string?)pair.Value,
        StringComparer.OrdinalIgnoreCase);

    var form = new Dictionary<string, object?>(StringComparer.OrdinalIgnoreCase);
    var files = new List<HarnessUploadedFile>();
    string? body = null;
    object? jsonBody = null;

    if (httpContext.Request.Method.Equals("POST", StringComparison.OrdinalIgnoreCase))
    {
        if (httpContext.Request.HasFormContentType)
        {
            var formCollection = await httpContext.Request.ReadFormAsync(new FormOptions
            {
                BufferBody = true
            });

            foreach (var pair in formCollection)
            {
                form[pair.Key] = pair.Value.Count == 1 ? pair.Value[0] : pair.Value.ToArray();
            }

            foreach (var file in formCollection.Files)
            {
                var tempPath = Path.GetTempFileName();
                await using var stream = File.OpenWrite(tempPath);
                await file.CopyToAsync(stream);
                files.Add(new HarnessUploadedFile(
                    Name: file.Name,
                    FileName: file.FileName,
                    ContentType: file.ContentType,
                    Length: file.Length,
                    TempPath: tempPath));
            }
        }
        else
        {
            using var reader = new StreamReader(httpContext.Request.Body);
            body = await reader.ReadToEndAsync();
            if (!string.IsNullOrWhiteSpace(body) && normalizer.TryParseJson(body, out var parsed))
            {
                jsonBody = parsed;
            }
        }
    }

    return new HarnessInvocationContext
    {
        DashboardId = options.DashboardId,
        SessionId = sessionId,
        PageId = options.PageId,
        ConnectionId = httpContext.Request.Headers["UDConnectionId"].FirstOrDefault(),
        EndpointId = endpointId,
        EventName = null,
        EventData = null,
        Location = null,
        Method = methodOverride ?? httpContext.Request.Method,
        Query = query,
        Headers = headers,
        Cookies = cookies,
        Form = form,
        Body = body,
        JsonBody = jsonBody,
        Files = files
    };
}

static string RenderShellPage(HttpContext httpContext, HarnessDefinition definition, HarnessOptions options)
{
    var baseUrl = WebUtility.HtmlEncode(httpContext.Request.PathBase.Value ?? string.Empty);
    var dashboardId = WebUtility.HtmlEncode(options.DashboardId);
    var title = WebUtility.HtmlEncode(definition.Shell.Title);
    var mountId = WebUtility.HtmlEncode(definition.Shell.MountId);
    var styles = string.Join(Environment.NewLine, definition.Shell.Styles.Select(style =>
        $"    <link rel=\"stylesheet\" href=\"{WebUtility.HtmlEncode(style)}\" />"));
    var scripts = string.Join(Environment.NewLine, definition.Shell.Scripts.Select(script =>
        $"    <script type=\"module\" src=\"{WebUtility.HtmlEncode(script)}\"></script>"));

    var body = definition.Shell.Scripts.Count > 0
        ? $"<div id=\"{mountId}\"></div>"
        : $"<main class=\"empty-state\"><h1>{title}</h1><p>No shell scripts were configured in {WebUtility.HtmlEncode(definition.SourcePath)}.</p></main>";

        return $$"""
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <meta name="baseurl" content="{{baseUrl}}" />
        <meta name="ud-dashboard" content="{{dashboardId}}" />
        <title>{{title}}</title>
        <style>
            :root {
                color-scheme: light;
                font-family: Consolas, 'Courier New', monospace;
                background: linear-gradient(135deg, #f5f0e8 0%, #f4f7fb 100%);
                color: #18212f;
            }

            body {
                margin: 0;
                min-height: 100vh;
            }

            #root {
                min-height: 100vh;
            }

            .empty-state {
                display: grid;
                min-height: 100vh;
                place-items: center;
                padding: 2rem;
                text-align: center;
            }

            .empty-state h1 {
                margin-bottom: 0.5rem;
                font-size: 2rem;
            }
        </style>
{{styles}}
        <script>
            window.__PSU_HARNESS__ = {
                dashboardId: '{{dashboardId}}',
                baseUrl: '{{baseUrl}}'
            };
        </script>
{{scripts}}
    </head>
    <body>
        {{body}}
    </body>
</html>
""";
}