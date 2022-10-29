class Island < ApplicationRecord
  belongs_to :user
  has_many :orders
  geocoded_by :location

  validates :name, :description, :price, :location, presence: true
  after_validation :geocode, if: :will_save_change_to_location?
end
