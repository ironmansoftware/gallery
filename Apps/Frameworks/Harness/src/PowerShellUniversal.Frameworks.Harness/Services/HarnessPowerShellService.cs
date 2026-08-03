using System.Text;
using System.Management.Automation;
using System.Management.Automation.Runspaces;
using PowerShellUniversal.Frameworks.Harness.Models;

namespace PowerShellUniversal.Frameworks.Harness.Services;

public sealed class HarnessPowerShellService(
    HarnessEndpointRegistry endpointRegistry,
    HarnessRealtimeService realtimeService,
    HarnessObjectNormalizer normalizer,
    ILogger<HarnessPowerShellService> logger)
{
    private readonly HarnessEndpointRegistry endpointRegistry = endpointRegistry;

    private const string HarnessPrelude = """
$Body = $HarnessContext.Body
$EventData = if ($null -ne $HarnessContext.EventData) {
    $HarnessContext.EventData
}
elseif ($null -ne $HarnessContext.JsonBody) {
    $HarnessContext.JsonBody
}
else {
    $HarnessContext.Body
}

$ConnectionId = $HarnessContext.ConnectionId
$DashboardId = $HarnessContext.DashboardId
$SessionId = $HarnessContext.SessionId
$PageId = $HarnessContext.PageId

$DashboardHub = [pscustomobject]@{}
$DashboardHub | Add-Member -MemberType ScriptMethod -Name SendWebSocketMessage -Value {
    param(
        [Parameter(Mandatory)]
        [object]$Arg1,

        [Parameter(Mandatory)]
        [object]$Arg2,

        [Parameter()]
        [object]$Arg3
    )

    if ($PSBoundParameters.ContainsKey('Arg3')) {
        $PsuHarness.SendMessage([string]$Arg2, $Arg3, [string]$Arg1, $DashboardId)
        return
    }

    $PsuHarness.SendMessage([string]$Arg1, $Arg2, $null, $DashboardId)
}

$DashboardHub | Add-Member -MemberType ScriptMethod -Name SendMessage -Value {
    param(
        [Parameter(Mandatory)]
        [string]$MessageType,

        [Parameter()]
        $Data,

        [Parameter()]
        [string]$ConnectionId,

        [Parameter()]
        [string]$DashboardId
    )

    $PsuHarness.SendMessage($MessageType, $Data, $ConnectionId, $DashboardId)
}

class Endpoint {
    static [object]$Registry
    [bool]$endpoint = $true
    [string]$name
    [string]$accept
    [string]$contentType
    hidden [scriptblock]$scriptBlock

    Endpoint([scriptblock]$scriptBlock) {
        $this.scriptBlock = $scriptBlock
    }

    [void] Register([string]$Id, [object]$Cmdlet) {
        if ($null -eq $this.scriptBlock) {
            throw 'Endpoint requires a script block.'
        }

        if (-not [string]::IsNullOrWhiteSpace($this.name)) {
            return
        }

        if ($null -eq [Endpoint]::Registry) {
            throw 'Endpoint registry has not been initialized for this runspace.'
        }

        $modulePaths = @(
            Get-Module |
                Where-Object { -not [string]::IsNullOrWhiteSpace($_.Path) } |
                Select-Object -ExpandProperty Path -Unique
        )

        $this.name = [Endpoint]::Registry.RegisterEndpoint($Id, $this.scriptBlock.ToString(), $modulePaths)
    }
}

[Endpoint]::Registry = $PsuHarness

function Send-PSUHarnessMessage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$MessageType,

        [Parameter()]
        $Data,

        [Parameter()]
        [string]$ConnectionId,

        [Parameter()]
        [string]$DashboardId
    )

    $PsuHarness.SendMessage($MessageType, $Data, $ConnectionId, $DashboardId)
}

function Set-PSUHarnessDownload {
    [CmdletBinding(DefaultParameterSetName = 'Content')]
    param(
        [Parameter(Mandatory)]
        [string]$Id,

        [Parameter(Mandatory)]
        [string]$FileName,

        [Parameter(ParameterSetName = 'Content', Mandatory)]
        [string]$Content,

        [Parameter(ParameterSetName = 'File', Mandatory)]
        [string]$Path,

        [Parameter()]
        [string]$ContentType = 'text/plain'
    )

    if ($PSCmdlet.ParameterSetName -eq 'File') {
        $PsuHarness.SetDownloadFromFile($Id, $FileName, $Path, $ContentType)
        return
    }

    $PsuHarness.SetDownloadText($Id, $FileName, $Content, $ContentType)
}

function Set-PSUHarnessSessionState {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$RequestId,

        [Parameter()]
        $State
    )

    $PsuHarness.SetSessionState($RequestId, $State)
}

function Get-PSUHarnessConnections {
    $PsuHarness.GetConnections()
}

function Show-UDToast {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Message,

        [ValidateSet('info', 'success', 'warning', 'error')]
        [string]$Type = 'info',

        [double]$Duration = 4.5
    )

    Send-PSUHarnessMessage -MessageType 'toast' -Data @{
        message = $Message
        type = $Type
        duration = $Duration
    }
}
""";

    public async Task<object?> InvokeBootstrapAsync(string scriptPath, HarnessInvocationContext context)
    {
        var output = await InvokeScriptAsync(scriptPath, context);
        return EnsureBootstrapShape(output, context);
    }

    public Task<object?> InvokeEndpointAsync(string scriptPath, HarnessInvocationContext context)
    {
        return InvokeScriptAsync(scriptPath, context);
    }

    private async Task<object?> InvokeScriptAsync(string scriptPath, HarnessInvocationContext context)
    {
        if (!File.Exists(scriptPath))
        {
            throw new FileNotFoundException($"Harness PowerShell script was not found: {scriptPath}", scriptPath);
        }

        logger.LogInformation("Executing PowerShell harness script {ScriptPath}", scriptPath);

        return await Task.Run(() =>
        {
            var initialSessionState = InitialSessionState.CreateDefault2();
            initialSessionState.ExecutionPolicy = Microsoft.PowerShell.ExecutionPolicy.Bypass;

            using var runspace = RunspaceFactory.CreateRunspace(initialSessionState);
            runspace.Open();

            using var powershell = PowerShell.Create();
            powershell.Runspace = runspace;
            var scriptDirectory = Path.GetDirectoryName(scriptPath) ?? Directory.GetCurrentDirectory();
            var scriptContent = File.ReadAllText(scriptPath);
            powershell.Runspace.SessionStateProxy.SetVariable("PSScriptRoot", scriptDirectory);
            powershell.Runspace.SessionStateProxy.SetVariable("PSCommandPath", scriptPath);
            powershell.Runspace.SessionStateProxy.SetVariable("HarnessScriptRoot", scriptDirectory);
            powershell.Runspace.SessionStateProxy.SetVariable("HarnessScriptPath", scriptPath);
            powershell.Runspace.SessionStateProxy.SetVariable("HarnessContext", context);
            powershell.Runspace.SessionStateProxy.SetVariable("PsuHarness", new PowerShellHarnessApi(this, realtimeService, context));
            powershell.AddScript(HarnessPrelude, useLocalScope: false);
            powershell.AddScript($"Set-Location -LiteralPath '{scriptDirectory.Replace("'", "''")}'", useLocalScope: false);
            powershell.AddScript(scriptContent, useLocalScope: false);

            var results = powershell.Invoke();
            if (powershell.HadErrors)
            {
                var errorText = string.Join(Environment.NewLine, powershell.Streams.Error.Select(error => error.ToString()));
                throw new InvalidOperationException($"Harness PowerShell execution failed.{Environment.NewLine}{errorText}");
            }

            return normalizer.NormalizeForJson(results.Count switch
            {
                0 => null,
                1 => results[0],
                _ => results
            });
        });
    }

    private object EnsureBootstrapShape(object? output, HarnessInvocationContext context)
    {
        Dictionary<string, object?> bootstrap;
        if (output is IReadOnlyDictionary<string, object?> dictionary && dictionary.ContainsKey("dashboard"))
        {
            bootstrap = new Dictionary<string, object?>(dictionary, StringComparer.OrdinalIgnoreCase);
        }
        else
        {
            bootstrap = new Dictionary<string, object?>(StringComparer.OrdinalIgnoreCase)
            {
                ["dashboard"] = output ?? new Dictionary<string, object?>(StringComparer.OrdinalIgnoreCase)
            };
        }

        bootstrap.TryAdd("sessionId", context.SessionId);
        bootstrap.TryAdd("pageId", context.PageId);
        bootstrap.TryAdd("dashboardName", "PSU Framework Harness");
        bootstrap.TryAdd("developerLicense", true);

        return bootstrap;
    }

    private sealed class PowerShellHarnessApi(HarnessPowerShellService outer, HarnessRealtimeService realtimeService, HarnessInvocationContext context)
    {
        public void SendMessage(string messageType, object? data, string? connectionId, string? dashboardId)
        {
            realtimeService
                .SendAsync(messageType, data, connectionId, string.IsNullOrWhiteSpace(dashboardId) ? context.DashboardId : dashboardId)
                .GetAwaiter()
                .GetResult();
        }

        public void SetDownloadText(string id, string fileName, string content, string contentType)
        {
            realtimeService.StoreDownload(new HarnessDownload(
                Id: id,
                FileName: fileName,
                ContentType: contentType,
                Content: Encoding.UTF8.GetBytes(content)));
        }

        public void SetDownloadFromFile(string id, string fileName, string path, string contentType)
        {
            realtimeService.StoreDownload(new HarnessDownload(
                Id: id,
                FileName: fileName,
                ContentType: contentType,
                Content: File.ReadAllBytes(path)));
        }

        public void SetSessionState(string requestId, object? state)
        {
            realtimeService.StoreSessionState(requestId, state);
        }

        public IReadOnlyList<HarnessConnection> GetConnections()
        {
            return realtimeService.GetConnections();
        }

        public string RegisterEndpoint(string componentId, string scriptContent, string[]? modulePaths)
        {
            return outer.endpointRegistry.RegisterEndpoint(componentId, scriptContent, modulePaths);
        }
    }
}
