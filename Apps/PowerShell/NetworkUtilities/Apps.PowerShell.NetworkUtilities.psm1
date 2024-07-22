function New-NetworkUtilityApp {
    $AppRoot = $PSScriptRoot

    New-UDApp -Title 'Network Utilities' -Content {
        New-UDTabs -Tabs {
            New-UDTab -Text 'Ping' -Content {
                New-UDForm -Children {
                    New-UDTextbox -Label "IP Address/Host Name" -Id 'pingHost'
                    New-UDCheckbox -Label 'Traceroute' -Id 'pingTraceroute'
                } -OnSubmit {

                    $traceroute = $EventData.pingTraceroute -eq $true
                    $Session:PingOutput = Test-NetConnection -ComputerName $EventData.pingHost -TraceRoute:$traceroute | Out-String
                    Sync-UDElement -Id 'pingOutput'
                }  -SubmitText "Ping"

                New-UDDynamic -Id 'pingOutput' -Content {
                    New-UDElement -Tag pre -Content {
                        $Session:PingOutput
                    }
                }
            }
            New-UDTab -Text 'Resolve' -Content {
                New-UDForm -Children {
                    New-UDTextbox -Label "DNS Name" -Id 'resolveName'
                } -OnSubmit {
                    $Session:ResolveOutput = Resolve-DnsName $EventData.resolveName | Out-String
                    Sync-UDElement -Id 'resolveOutput'
                }  -SubmitText "Resolve"

                New-UDDynamic -Id 'resolveOutput' -Content {
                    New-UDElement -Tag pre -Content {
                        $Session:ResolveOutput
                    }
                }
            }
            New-UDTab -Text 'Speed Test' -Content {
                New-UDButton -Text 'Run Speed Test' -OnClick {
                    Write-Progress -Activity "Running speed test..."
                    $Speedtest = & "$AppRoot\speedtest.exe" --format=json --accept-license --accept-gdpr
                    $Speedtest = $Speedtest | ConvertFrom-Json

                    [PSCustomObject]$SpeedObject = @{
                        downloadspeed = [math]::Round($Speedtest.download.bandwidth / 1000000 * 8, 2)
                        uploadspeed   = [math]::Round($Speedtest.upload.bandwidth / 1000000 * 8, 2)
                        packetloss    = [math]::Round($Speedtest.packetLoss)
                        isp           = $Speedtest.isp
                        ExternalIP    = $Speedtest.interface.externalIp
                        InternalIP    = $Speedtest.interface.internalIp
                        UsedServer    = $Speedtest.server.host
                        URL           = $Speedtest.result.url
                        Jitter        = [math]::Round($Speedtest.ping.jitter)
                        Latency       = [math]::Round($Speedtest.ping.latency)
                    }

                    $Session:Speed = [PSCustomObject]$SpeedObject
                    Sync-UDElement -Id 'speedResult'
                } -ShowLoading

                New-UDDynamic -Id 'speedResult' -Content {
                    New-UDElement -Tag pre -Content {
                        $Session:Speed | Out-String
                    }
                }
            }
        }
    }
}