class ForecastsController < ApplicationController
  def show    
    @address_default = "1 Infinite Loop, Cupertino, California"
    session[:address] = params[:address]
    @histories = current_user.search_histories.last(4).reverse
    if params[:address]
      begin
        @address = params[:address]
        @geocode = GeocodeService.call(@address)
        @weather_cache_key = "#{@geocode.country_code}/#{@geocode.postal_code}"
        @weather = Rails.cache.fetch(@weather_cache_key, expires_in: 30.minutes) do
          WeatherService.call(@geocode.latitude, @geocode.longitude)          
        end
                
        unless current_user.search_histories.find_by_postal_code(@geocode.postal_code)
          weather_params = create_weather_params(@weather, @geocode.postal_code, @address)
          current_user.search_histories.create!(weather_params)
        end
      rescue => e
        flash.alert = e.message
      end
    end
  end

  def update_search
    SearchHistoryWorker.perform_async
    flash[:notice] = "Weather Status Has Been Updated"
    redirect_to(:controller => 'forecasts', :action => 'show')
  end

  private 

  def create_weather_params(weather, code, town)
    { temperature: weather.temperature,temperature_min: weather.temperature_min, temperature_max: weather.temperature_max,humidity: weather.humidity,pressure: weather.pressure, description: weather.description,postal_code: code,town: town }
  end  
end
