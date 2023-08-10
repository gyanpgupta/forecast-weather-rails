class SearchHistoriesController < ApplicationController
  def index
    @histories = current_user.search_histories
    render json: @histories
  end 
end
