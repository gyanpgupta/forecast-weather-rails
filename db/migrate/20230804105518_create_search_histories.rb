class CreateSearchHistories < ActiveRecord::Migration[7.0]
  def change
    create_table :search_histories do |t|
      t.string :temperature
      t.string :temperature_min
      t.string :temperature_max
      t.string :humidity
      t.string :pressure
      t.string :description
      t.string :town
      t.integer :postal_code

      t.timestamps
    end
  end
end
