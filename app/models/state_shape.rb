class StateShape < ActiveRecord::Base
  self.table_name = 'states_shapes'
  self.primary_key = 'cd_geocuf'

  has_many :cities
  has_many :segments, through: :cities
  belongs_to :country
end
