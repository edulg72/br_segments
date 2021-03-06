class City < ActiveRecord::Base
  has_many :streets
  has_many :segments, through: :streets
  has_one :city_shape, foreign_key: :city_id
  belongs_to :state
end
