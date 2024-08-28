New-PSUHealthCheck -Name "Internet Access" -Description "Check if the server has internet access" -ScriptBlock {
    if (-not (Test-Connection -ComputerName ironmansoftware.com -Count 1 -Quiet)) {
        New-PSUHealthCheckResult -Level Error -Message "The server does not have internet access."
        return 
    }

    New-PSUHealthCheckResult -Level Ok -Message "The server has internet access."
}