$payload = $HarnessContext.JsonBody

if ($null -eq $payload) {
    $payload = $HarnessContext.Body
}

@{
    ok = $true
    endpoint = $HarnessContext.EndpointId
    method = $HarnessContext.Method
    received = $payload
}
