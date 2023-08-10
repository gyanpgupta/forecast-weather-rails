class SearchHistoryWorker
  include Sidekiq::Worker

  def perform
    search_histories = SearchHistory.all
    search_histories.each do |history|
      geocode = GeocodeService.call(history.town)
      weather_cache_key = "#{geocode.country_code}/#{geocode.postal_code}"
      weather = Rails.cache.fetch(weather_cache_key, expires_in: 30.minutes) do
        WeatherService.call(geocode.latitude, geocode.longitude)          
      end
      history.update(temperature: weather.temperature,description: weather.description )
    end
  end
end
