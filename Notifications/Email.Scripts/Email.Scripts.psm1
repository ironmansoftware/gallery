param(
    [Parameter(Mandatory, ParameterSetName = 'AppToken')]
    $AppToken,
    [Parameter(Mandatory, ParameterSetName = 'Job')]
    $Job,
    [Parameter(Mandatory, ParameterSetName = 'Dashboard')]
    $Dashboard,
    [Parameter(Mandatory, ParameterSetName = 'Endpoint')]
    $Endpoint,
    [Parameter(Mandatory, ParameterSetName = 'License')]
    $License,
    [Parameter(Mandatory, ParameterSetName = 'User')]
    $User,
    [Parameter(Mandatory, ParameterSetName = 'HealthCheck')]
    $HealthCheck,
    [Parameter()]
    $Data
)

if ($PSCmdlet.ParameterSetName -eq 'Job') {
    $Output = Get-PSUJob -Id $Job.Id | Get-PSUJobOutput | Select-Object -First 10 | ForEach-Object { "$_`r`n" }

    $Output = [AnsiConsoleToHtml.AnsiConsole]::ToHtml($Output)

    $Description = "<p>Started: $($Job.StartTime)</p>"
    $Description += "<p>Environment: $($Job.Environment)</p>"
    if ($Job.Schedule) {
        $Description += "<p>Schedule: $($Job.Schedule)</p>"
    }

    $Description += "<p>Identity: $($Job.Identity.Name)</p>"

    $EmailBody = "<html><body><h1>Job $($Job.Status.ToString()) - $($Job.ScriptFullPath) ($($Job.Id))</h1>$Description<pre>$Output</pre><a href=`"$ApiUrl/admin/automation/jobs/$($Job.Id)`">View Job</a></body></html>"
    $Subject = "PowerShell Universal Job $($Job.Status.ToString()) - $($Job.ScriptFullPath) ($($Job.Id))"
}
else {
    $Trigger = Get-PSUTrigger | Where-Object Name -eq $UAJob.Trigger
    switch ($Trigger.EventType) {
        ([PowerShellUniversal.EventType]::ServerStarted) {
            $EmailBody = "<html><body><h1>PowerShell Universal Server Started - $($env:ComputerName)</h1><a href=`"$ApiUrl`">View</a></body></html>"
            $Subject = "PowerShell Universal Server Started - $($env:ComputerName)"
        }
        ([PowerShellUniversal.EventType]::DashboardStarted) {
            $EmailBody = "<html><body><h1>PowerShell Universal App Started - $($Dashboard.Name)</h1><a href=`"$ApiUrl/admin/apps`">View</a></body></html>"
            $Subject = "PowerShell Universal App Stopped - $($Dashboard.Name)"
        }
        ([PowerShellUniversal.EventType]::DashboardStopped) {
            $EmailBody = "<html><body><h1>PowerShell Universal App Stopped - $($Dashboard.Name)</h1><a href=`"$ApiUrl/admin/apps`">View</a></body></html>"
            $Subject = "PowerShell Universal App Stopped - $($Dashboard.Name)"
        }
        ([PowerShellUniversal.EventType]::NewUserLogin) {
            $EmailBody = "<html><body><h1>PowerShell Universal New User Login - $($User.Name)</h1><a href=`"$ApiUrl/admin/security/identities`">View</a></body></html>"
            $Subject = "PowerShell Universal New User Login - $($User.Name)"
        }
        ([PowerShellUniversal.EventType]::RevokedAppTokenUsage) {
            $EmailBody = "<html><body><h1>PowerShell Universal Revoked App Token Usage - $($AppToken.Description)</h1><a href=`"$ApiUrl/admin/security/tokens`">View</a></body></html>"
            $Subject = "PowerShell Universal Revoked App Token Usage - $($AppToken.Description)"
        }
        ([PowerShellUniversal.EventType]::ApiAuthenticationFailed) {
            $EmailBody = "<html><body><h1>PowerShell Universal API Authentication Failure - $($Data.Url)</h1><a href=`"$ApiUrl/admin/apis/endpoints`">View</a></body></html>"
            $Subject = "PowerShell Universal API Authentication Failure - $($Data.Url)"
        }
        ([PowerShellUniversal.EventType]::ApiError) {
            $EmailBody = "<html><body><h1>PowerShell Universal API Error - $($Data.Url)</h1><a href=`"$ApiUrl/admin/apis/endpoints`">View</a></body></html>"
            $Subject = "PowerShell Universal API Error - $($Data.Url)"
        }
        ([PowerShellUniversal.EventType]::LicenseExpiring) {
            $Description = "Your PowerShell Universal license is expiring soon."
            $EmailBody = "<html><body><h1>PowerShell Universal License Expiring - $($License.EndDate.ToShortDate())</h1><a href=`"$ApiUrl/admin/settings/licenses`">View</a></body></html>"
            $Subject = "PowerShell Universal  icense Expiring - $($License.EndDate.ToShortDate())"
        }
        ([PowerShellUniversal.EventType]::LicenseExpired) {
            $Description = "Your PowerShell Universal license is expired."
            $EmailBody = "<html><body><h1>PowerShell Universal License Expired - $($License.EndDate.ToShortDate())</h1><a href=`"$ApiUrl/admin/settings/licenses`">View</a></body></html>"
            $Subject = "PowerShell Universal License Expired - $($License.EndDate.ToShortDate())"
        }
        ([PowerShellUniversal.EventType]::HealthCheckFailed) {
            $EmailBody = "<html><body><h1>PowerShell Universal Health Check Failed - $($HealthCheck.Name)</h1>$($HealthCheck.Message)<a href=`"$ApiUrl/admin/platform/health-checks`">View</a></body></html>"
            $Subject = "PowerShell Universal Health Check Failed - $($HealthCheck.Name)"
        }
    }
}

$Parameters = @{
    From    = @{
        Name  = $PSUTriggerEmailFromName
        Email = $PSUTriggerEmailFromEmail
    }
    To      = $PSUTriggerEmailToEmail
    Subject = $Subject
    Html    = $EmailBody
}

if ($Secret:PSUTriggerEmailGraphClientId) {
    $Parameters.Credential = ConvertTo-GraphCredential -ClientID $Secret:PSUTriggerEmailGraphClientId -ClientSecret $Secret:PSUTriggerEmailGraphClientSecret -DirectoryID $Secret:PSUTriggerEmailGraphDirectoryId
    $Parameters.Graph = $true
}
elseif ($Secret:PSUTriggerEmailCredential) {
    $Parameters.Credential = $Secret:PSUTriggerEmailCredential
    $Parameters.Server = $PSUTriggerEmailServer
    $Parameters.SecureSocketOptions = 'Auto'
}

$Parameters

Send-EmailMessage @Parameters