class StateShape < ActiveRecord::Base
  self.table_name = 'states_shapes'
  self.primary_key = 'cd_geocuf'

  has_many :cities, foreign_key: 'state_id', class_name: 'CityShape'
  has_many :segments, through: :cities
  has_many :streets, through: :segments
  belongs_to :country

  def name
    "#{nm_estado}"
  end
end
