# Weather forecaster app with Ruby on Rails 


## Scope

1. Use Ruby On Rails. 

2. Accept an address as input. 

3. Retrieve forecast data for the given address. This should include, at minimum, the current temperature. Bonus points: retrieve high/low and/or extended forecast.

4. Display the requested forecast details to the user.

5. Cache the forecast details for 30 minutes for all subsequent requests by zip codes. Display indicator in result is pulled from cache.


### Install Rails

Install Ruby on Rails:

```sh
% gem install rails
```

## Set up the app

### Add flash

I like to use Rails flash messages to show the user notices, alerts, and the like. I use some simple CSS to make the styling easy.

Add flash messages that are rendered via a view partial:

```sh
% mkdir app/views/shared
```

Create `app/views/shared/_flash.html.erb`:

```ruby
<% flash.each do |type, message| %>
  <div class="flash flash-<%= type %>">
    <%= message %>
  </div>
<% end %>
```


## Accept an address as input

We want a controller can accept an address as an input parameter. 

A simple way to test this is by saving the address in the session.


### Add faker gem

To create test data, we can use the `faker` gem, which can create fake addresses.

Edit `Gemfile` and its `test` section to add the `faker` gem:

```ruby
gem "faker"
```

Run:

```sh
bundle
```


### Generate forecasts controller

Generate a forecasts controller and its tests:

```sh
% bin/rails generate controller forecasts show
```

Write a test in `test/controllers/forecasts_controller_test.rb`:

```ruby
require "test_helper"

class ForecastControllerTest < ActionDispatch::IntegrationTest

  test "show with an input address" do
    address = Faker::Address.full_address
    get forecasts_show_url, params: { address: address }
    assert_response :success
    assert_equal address, session[:address]
  end

end
```

Generate a system test that will launch the web page, and provide the correct placeholder for certain future work:

```
% bin/rails generate system_test forecasts
```

Write a test in `test/system/forecasts_test.rb`:

```ruby
require "application_system_test_case"

class ForecastsTest < ApplicationSystemTestCase

  test "show" do
    address = Faker::Address.full_address
    visit url_for \
      controller: "forecasts", 
      action: "show", 
      params: { 
        address: address 
      }
    assert_selector "h1", text: "Forecasts#show"
  end

end
```

TDD should fail:

```sh
% bin/rails test:all
```

Implement in `app/controllers/forecasts_controller.rb`:


```ruby
class ForecastsController < ApplicationController

  def show
    session[:address] = params[:address]
  end

end
```

TDD should succeed:

```sh
% bin/rails test:all
```


### Set the root path route

Edit `config/routes.rb`:

```ruby
# Defines the root path route ("/")
root "forecasts#show"
```




### Set ArcGIS API credentials

Edit Rails credentials:

```sh
EDITOR="code --wait"  bin/rails credentials:edit
```

Add your ArcGIS credentials by replacing these fake credentials with your real credentials:

```ruby
arcgis_api_user_id: alice
arcgis_api_secret_key: 6d9ecd1c-2b00-4a0e-89d7-8f250418a9c4
```


### Add Geocoder gem

Ruby has an excellent way to access the ArcGIS API, by using the Geocoder gem, and configuring it for the ArcGIS API.

Edit `Gemfile` to add:

```ruby
# Look up a map address and convert it to latitude, longitude, etc.
gem "geocoder"
```

Run:

```sh
bundle
```


### Configure Geocoder

Create `config/initializers/geocoder.rb`:

```ruby
Geocoder.configure(
    esri: {
        api_key: [
            Rails.application.credentials.arcgis_api_user_id, 
            Rails.application.credentials.arcgis_api_secret_key,
        ], 
        for_storage: true
    }
)
```


### Create GeocodeService

We want to create a geocode service that converts from an address string into a latitude, longitude, country code, and postal code.

Create `test/services/geocode_service_test`:

```ruby
require 'test_helper'

class GeocodeServiceTest < ActiveSupport::TestCase

  test "call with known address" do
    address = "1 Infinite Loop, Cupertino, California"
    geocode = GeocodeService.call(address)
    assert_in_delta 37.33, geocode.latitude, 0.1
    assert_in_delta -122.03, geocode.longitude, 0.1
    assert_equal "us", geocode.country_code
    assert_equal "95014", geocode.postal_code
  end

end
```



## Join OpenWeather API

Sign up at <https://openweathermap.org>

* The process creates your API key.

Example:

* OpenWeather API key: 70a6c8131f03fe7a745b6b713ed9ebfd



### Set OpenWeather API credentials

Edit Rails credentials:

```sh
EDITOR="code --wait"  bin/rails credentials:edit
```

Add your OpenWeather credentials by replacing these fake credentials with your real credentials:

```ruby
openweather_api_key: 70a6c8131f03fe7a745b6b713ed9ebfd
```



### Create WeatherService

Create `test/services/weather_service_test.rb`:

```ruby
require 'test_helper'

class WeatherServiceTest < ActiveSupport::TestCase

  test "call with known parameters" do
    # Example address is 1 Infinite Loop, Cupertino, California
    latitude = 37.331669
    longitude = -122.030098 
    weather = WeatherService.call(latitude, longitude)
    assert_includes -4..44, weather.temperature
    assert_includes -4..44, weather.temperature_min
    assert_includes -4..44, weather.temperature_max
    assert_includes 0..100, weather.humidity
    assert_includes 900..1100, weather.pressure
    refute_empty weather.description
  end

end
```




## Complete the app

In the interest of time, I'll complete the app by doing the forecasts controller and view. Use of TDD and/or step-by-step additions are shown above, so are elided below.






Update `test/system/forecasts_test.rb`:

```ruby
assert_selector "h1", text: "Forecast"
```


### Enable the cache

Enable the Rails development cache, so a developer can see that the forecasts are cached as expected.


```sh
bin/rails dev:cache
```


## Conclusion

The app now works successfully:

```sh
% bin/rails test
% bin/rails test:system
% bin/rails server -d
```

Browse to <http://127.0.0.1:3000>

I hope you've enjoyed seeing this app. It's a quick demonstration of Ruby on Rails, Test Driven Development, API access using a specialized gem (i.e. geocoder) and a generalized gem (i.e. faraday).


### Future ideas

Add functional tests, such as for flash messages, error messages, the search form, the API reachability, etc.

Add internationalitzation/localization for messages and temperature units.

Add deployment capabilties, such as to Heroku, or AWS, or GCP.

Add continous integration and continuous delivery, such as via GitHub actions.

Add styles, such as for fonts, colors, a page header, a page footer, etc.

Add circuit breakers that can detect when the app load is too high to be viable for the API calls.

Add API capabilties, such as returning JSON, or offering gRPC, etc.


### setup with docker

run docker-compose build
run docker-compose up
"Your application should now be up and running at http://localhost:3000."

### OpenAI ChatGPT comparison

I'm currently experimenting with AI/ML for programming, such as with GitHub Copilot and OpenAI ChatGPT.

The OpenAI ChatGPT is notable, in my opinion, because it gets in the right ballpark of what Ruby on Rails code could look like, but it doesn't actually run, and doesn't create services, or API credentials, etc.

I believe AI/ML is a promising area to explore, so I'm including this appendix section that shows the OpenAI ChatGPT reply to the original requirements documentation.

ChatGPT says:

* In this implementation, the ForecastController's show action accepts an address as input and retrieves the forecast data for that address using the Forecast.for_address class method. 

* This method uses Rails' built-in caching mechanism to store the forecast data in memory for 30 minutes, so that subsequent requests for the same address will not have to hit the weather API again and can instead return the cached data. 

* The from_cache attribute of the Forecast object is set to true if the data was retrieved from the cache. The controller then renders the forecast data as a JSON object, including the current temperature, high and low temperatures, extended forecast, and a from_cache flag indicating whether the data was retrieved from the cache or not.

```ruby
# app/controllers/forecast_controller.rb
class ForecastController < ApplicationController
  def show
    # Accept an address as input
    address = params[:address]

    # Retrieve forecast data for the given address
    forecast = Forecast.for_address(address)

    # Display the requested forecast details to the user
    render json: {
      current_temperature: forecast.current_temperature,
      high: forecast.high,
      low: forecast.low,
      extended_forecast: forecast.extended_forecast,
      from_cache: forecast.from_cache
    }
  end
end
```


```ruby
# app/models/forecast.rb
class Forecast
  CACHE_EXPIRATION = 30.minutes

  attr_reader :current_temperature, :high, :low, :extended_forecast, :from_cache

  def initialize(attributes)
    @current_temperature = attributes[:current_temperature]
    @high = attributes[:high]
    @low = attributes[:low]
    @extended_forecast = attributes[:extended_forecast]
    @from_cache = attributes[:from_cache]
  end

  def self.for_address(address)
    Rails.cache.fetch("forecast-#{address}", expires_in: CACHE_EXPIRATION) do
      # Retrieve the forecast data from a weather API or other source
      forecast_data = retrieve_forecast_data(address)

      # Create a Forecast object with the retrieved data
      new(
        current_temperature: forecast_data[:current_temperature],
        high: forecast_data[:high],
        low: forecast_data[:low],
        extended_forecast: forecast_data[:extended_forecast],
        from_cache: false
      )
    end
  end

  private

  def self.retrieve_forecast_data(address)
    # Code to retrieve forecast data from a weather API or other source
  end
end
```
