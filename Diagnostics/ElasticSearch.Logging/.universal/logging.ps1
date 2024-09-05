if (-not $PSUElasticLoggingLevel) {
    $PSUElasticLoggingLevel = "Information"
}

if (-not $PSUElasticHostName) {
    throw "The PSUElasticHostName variable is not set. Please set this variable to the hostname of the ElasticSearch server."
}

if (-not $PSUElasticPort) {
    throw "The PSUElasticPort variable is not set. Please set this variable to the port of the ElasticSearch server."
}

New-PSULoggingTarget -Type "TCP" -Level $PSUElasticLoggingLevel -Properties @{
    hostName = "tcp://$PSUElasticHostName"
    port     = $PSUElasticPort
} -Scope "User"

New-PSULoggingTarget -Type "TCP" -Level $PSUElasticLoggingLevel -Properties @{
    hostName = "tcp://$PSUElasticHostName"
    port     = $PSUElasticPort
} -Scope "System"