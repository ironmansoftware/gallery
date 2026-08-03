function Show-AntDesignMessage {
    <#
    .SYNOPSIS
    Shows an Ant Design global message in the current dashboard session.

    .DESCRIPTION
    Sends a dashboard websocket message through the built-in DashboardHub variable so the Ant Design client runtime can display a global message. Use this for lightweight feedback after an action completes or while work is in progress.

    .NOTES
    Use messages for short, non-blocking feedback such as success, warning, error, info, and loading states.
    When invoked inside a dashboard endpoint, the current ConnectionId is used automatically when available.
    Use -Broadcast to send the message to every connected client for the current dashboard.

    .PARAMETER Content
    Specifies the message content rendered by the Ant Design Message component.

    .PARAMETER Type
    Specifies the Ant Design message type.

    .PARAMETER Duration
    Specifies how long the message should stay visible, in seconds. Use 0 to keep it open until it is replaced or destroyed by a later update.

    .PARAMETER Key
    Specifies a stable key so later calls can update the same message instance.

    .PARAMETER Broadcast
    Sends the message to all connected clients for the current dashboard.

    .EXAMPLE
    New-UDAntDesignButton -Text 'Save Changes' -Type primary -OnClick {
        Show-AntDesignMessage -Content 'Saved changes.' -Type success
    }

    Displays a success message from a button click inside the current dashboard session.

    .EXAMPLE
    New-UDAntDesignButton -Text 'Start Sync' -OnClick {
        Show-AntDesignMessage -Content 'Sync in progress...' -Type loading -Duration 0 -Key 'sync-status'
    }

    Starts a persistent loading message that later endpoint calls can update by reusing the same key.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [Alias('Message')]
        [string]$Content,
        [ValidateSet('info', 'success', 'warning', 'error', 'loading')]
        [string]$Type = 'info',
        [double]$Duration,
        [string]$Key,
        [switch]$Broadcast
    )

    if (-not $DashboardHub) {
        throw 'Show-AntDesignMessage requires the PowerShell Universal DashboardHub context.'
    }

    $targetConnectionId = Get-Variable -Name 'ConnectionId' -ValueOnly -ErrorAction Ignore

    $data = @{
        content = $Content
        type    = $Type
    }

    if ($PSBoundParameters.ContainsKey('Duration')) {
        $data.duration = $Duration
    }

    if ($PSBoundParameters.ContainsKey('Key')) {
        $data.key = $Key
    }

    if ($Broadcast) {
        $DashboardHub.SendWebSocketMessage('antdesign-message', $data)
        return
    }

    if ([string]::IsNullOrWhiteSpace($targetConnectionId)) {
        throw 'Show-AntDesignMessage requires -Broadcast or a ConnectionId in the current dashboard endpoint context.'
    }

    $DashboardHub.SendWebSocketMessage($targetConnectionId, 'antdesign-message', $data)
}