class Area < ActiveRecord::Base
  self.table_name = 'areas_mapraid'
  
  has_many :cities, class_name: 'CityMapraid'
  has_many :segments, through: :cities
  
  scope :mapraid, -> {where('id in (21,22)')}
  scope :others, -> {where('id not in (21,22)')}
end
