# Weather Components

This module contains weather components that can be used in apps. 

## Components 

### `New-UDWeatherCard`

Displays the weather as a card in your app. You can use the `-Location` parameter to configure the location that the weather card will display for. It supports the following formats: 

```
paris                  # city name
~Eiffel+tower          # any location (+ for spaces)
Москва                 # Unicode name of any location in any language
muc                    # airport code (3 letters)
@stackoverflow.com     # domain name
94107                  # area codes
-78.46,106.79          # GPS coordinates
```

![Weather Card](https://raw.githubusercontent.com/ironmansoftware/scripts/main/images/Misc/Weather.Apps.png)
