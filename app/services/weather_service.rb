require 'faraday'
require 'faraday_middleware'

class WeatherService  

  def self.call(latitude, longitude)
    started = Time.now    
    conn = Faraday.new("https://api.openweathermap.org") do |f|
      f.use :http_cache, store: Rails.cache, logger: ActiveSupport::Logger.new(STDOUT)
      f.adapter Faraday.default_adapter
      f.request :json # encode req bodies as JSON and automatically set the Content-Type header
      f.request :retry # retry transient failures
      f.response :json # decode response bodies as JSON
      f.use Faraday::OverrideCacheControl, cache_control: 'public, max-age=3600'
    end    
    response = conn.get('/data/2.5/weather', {
      appid: ENV['KEY'],
      lat: latitude,
      lon: longitude,
      units: "metric",
    })
    ended = Time.now
    puts "#{ended - started} Time is taken by api"
    body = response.body
    body or raise IOError.new "OpenWeather response body failed"
    body["main"] or raise IOError.new "OpenWeather main section is missing"
    body["main"]["temp"] or raise IOError.new "OpenWeather temperature is missing"
    body["main"]["temp_min"] or raise IOError.new "OpenWeather temperature minimum is missing"
    body["main"]["temp_max"] or raise IOError.new "OpenWeather temperature maximum is missing"
    body["weather"] or raise IOError.new "OpenWeather weather section is missing"
    body["weather"].length > 0 or raise IOError.new "OpenWeather weather section is empty"
    body["weather"][0]["description"] or raise IOError.new "OpenWeather weather description is missing"
    weather = OpenStruct.new
    weather.temperature = body["main"]["temp"]
    weather.temperature_min = body["main"]["temp_min"]
    weather.temperature_max = body["main"]["temp_max"]
    weather.humidity = body["main"]["humidity"]
    weather.pressure = body["main"]["pressure"]
    weather.description = body["weather"][0]["description"]
    weather
  end
    
end
