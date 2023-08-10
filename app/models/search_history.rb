class SearchHistory < ApplicationRecord
  validates :postal_code, uniqueness: { scope: :user_id }
  belongs_to :user
end