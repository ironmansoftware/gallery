New-PSUEndpoint -Url "/system" -Description "Returns information about the system. " -Method @('GET') -Endpoint {
    Get-ComputerInfo
} -Authentication -Role @('Administrator', 'System API Reader') -Documentation "System Endpoints" 
New-PSUEndpoint -Url "/system/process" -Description "Returns processes running on the system." -Method @('GET') -Endpoint {
    # Enter your script to process requests.
    Get-Process | ConvertTo-Json -Depth 1
} -Authentication -Role @('Administrator', 'System API Reader') -Documentation "System Endpoints" 
New-PSUEndpoint -Url "/system/drive" -Description "Returns drive information for the system." -Method @('GET') -Endpoint {
    # Select only top level properties to improve performance
    Get-PSDrive -PSProvider 'FileSystem' | ConvertTo-Json -Depth 1
} -Authentication -Role @('Administrator', 'System API Reader') -Documentation "System Endpoints" 
New-PSUEndpoint -Url "/system/network" -Description "Returns network information for the system." -Method @('GET') -Endpoint {
    # Select only top level properties to improve performance
    Get-NetAdapter | ConvertTo-Json -Depth 1
} -Authentication -Role @('Administrator', 'System API Reader') -Documentation "System Endpoints"