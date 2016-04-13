class CityShape < ActiveRecord::Base
  self.table_name = 'cities_shapes'
  self.primary_key = 'cd_geocmu'
  
  belongs_to :state
  belongs_to :city, foreign_key: :city_id, class_name: 'City'
  has_many :segments, foreign_key: :city_id
  
end
