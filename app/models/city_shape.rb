class CityShape < ActiveRecord::Base
  self.table_name = 'cities_shapes'
#  self.primary_key = 'cd_geocmu'

  belongs_to :state, foreign_key: :state_id, class_name: 'StateShape'
  belongs_to :city, foreign_key: :city_id, class_name: 'City'
  has_many :segments, -> { includes :street }, foreign_key: :city_id

  def name
    "#{nm_municip}"
  end

end
