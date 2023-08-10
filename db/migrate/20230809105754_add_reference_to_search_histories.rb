class AddReferenceToSearchHistories < ActiveRecord::Migration[7.0]
  def change
    add_reference :search_histories, :user, foreign_key: true
  end
end
