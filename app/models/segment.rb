class Segment < ActiveRecord::Base
  self.table_name = 'vw_segments'
  self.primary_key = 'id'

  belongs_to :editor, foreign_key: 'last_edit_by', class_name: 'User'
  belongs_to :street
  belongs_to :city, foreign_key: 'city_id',class_name: 'CityShape'

  scope :drivable, -> {where(roadtype: [1,2,3,4,6,7,8,15,17,20])}
  scope :important, -> {where(roadtype: [3,4,6,7])}
  scope :roads, -> {where(roadtype: [3,6,7])}
  scope :disconnected, -> {where('not connected')}
  scope :no_name, -> {where('street_id is null and not validated')}
  scope :without_name, -> {joins('left outer join vw_streets on vw_streets.id = vw_segments.street_id').where('(street_id is null or vw_streets.isempty) and not alt_names')}
  scope :with_speed, -> {where('(not fwddirection or fwdmaxspeed is not null) and (not revdirection or revmaxspeed is not null)')}
  scope :without_speed, -> {where('((fwddirection and fwdmaxspeed is null) or (revdirection and revmaxspeed is null))')}
  scope :no_roundabout, -> {where('roundabout is null or not roundabout')}

  def self.lock_level(max_lock)
    where("lock is null or lock <= ?",max_lock)
  end
end
