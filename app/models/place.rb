class Place < ActiveRecord::Base
  self.table_name = 'vw_places'
  self.primary_key = 'id'

  belongs_to :creator, foreign_key: 'created_by', class_name: 'User'
  belongs_to :editor, foreign_key: 'updated_by', class_name: 'User'
  belongs_to :city, foreign_key: 'city_id', class_name: 'CityShape'
end
