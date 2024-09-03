function New-UDWeatherCard {
    <#
    .SYNOPSIS
    Displays the weather in a card. 
    
    .DESCRIPTION
    Displays the weather in a card. Uses the wttr.in API to retrieve weather information.
    
    .PARAMETER Location
    The location to retrieve weather for. 

    Supported location types:

    paris                  # city name
    ~Eiffel+tower          # any location (+ for spaces)
    Москва                 # Unicode name of any location in any language
    muc                    # airport code (3 letters)
    @stackoverflow.com     # domain name
    94107                  # area codes
    -78.46,106.79          # GPS coordinates
    #>
    param($Location = "Madison, WI")
    New-UDCard -Title "Current Weather: $Location" -Content {
        New-UDDynamic -Content {
            $Weather = Invoke-RestMethod http://wttr.in/${location}?format=j1 -UserAgent "curl"

            $Temp = $Weather.current_condition.temp_F
            $TempC = $Weather.current_condition.temp_C
            $Precip = $Weather.current_condition.precipMM
            $Humidity = $Weather.current_condition.humidity
            $WindSpeed = $Weather.current_condition.windspeedKmph
            $WindDir = $Weather.current_condition.winddir16Point
            $Clouds = $Weather.current_condition.cloudcover
            $Desc = $Weather.current_condition.weatherDesc.value

            New-UDTypography -Text $Desc

            New-UDTypography -Variant h3 -Content {
                New-UDIcon -Icon TemperatureHalf
                "$Temp F ($TempC C)"
            }

            New-UDDivider

            New-UDStack -Direction row -Children {
                New-UDTooltip -Content {
                    New-UDTypography -Variant h4 -Content {
                        New-UDIcon -Icon Cloud
                        "  $Clouds%"
                    }
                } -TooltipContent { "Cloud Cover" }

                New-UDTooltip -Content {
                    New-UDTypography -Variant h4 -Content {
                        New-UDIcon -Icon Wind
                        "  $WindSpeed $WindDir"
                    } -Style @{
                        marginLeft = '5px'
                    }
                } -TooltipContent { "Wind Speed and Direction" }
            }

            New-UDDivider

            New-UDStack -Direction row -Children {
                New-UDTooltip -Content {
                    New-UDTypography -Variant h4 -Content {
                        New-UDIcon -Icon CloudRain
                        "  $Precip mm"
                    } -Style @{
                        marginLeft = '5px'
                    }
                } -TooltipContent { "Precipitation" }

                New-UDTooltip -Content {
                    New-UDTypography -Variant h4 -Content {
                        New-UDIcon -Icon Droplet
                        "  $Humidity %"
                    } -Style @{
                        marginLeft = '5px'
                    }
                } -TooltipContent { "Humidity" }

            }
        } -LoadingComponent {
            New-UDSkeleton
            New-UDSkeleton
            New-UDSkeleton
            New-UDSkeleton
        }
    } 
}