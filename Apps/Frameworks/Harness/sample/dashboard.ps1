$message = 'Harness ready'

if ($null -ne $HarnessContext -and $HarnessContext.Query.ContainsKey('message')) {
    $message = [string]$HarnessContext.Query['message']
}

@{
    dashboard = @{
        type = 'antd-text'
        id = 'root-text'
        text = $message
        content = @(
            @{
                type = 'antd-button'
                id = 'http-button'
                text = 'Invoke HTTP endpoint'
                onClick = @{
                    endpoint = $true
                    name = 'demo-button'
                }
            },
            @{
                type = 'antd-button'
                id = 'server-push-button'
                text = 'Invoke server push flow'
                onClick = @{
                    endpoint = $true
                    name = 'demo-websocket'
                }
            }
        )
    }
    dashboardName = 'Framework Harness Demo'
    developerLicense = $true
}
