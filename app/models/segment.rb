class Segment < ActiveRecord::Base
  self.table_name = 'vw_segments'
  self.primary_key = 'id'

  belongs_to :editor, foreign_key: 'last_edit_by', class_name: 'User'
  belongs_to :street
  belongs_to :city, foreign_key: 'city_id', class_name: 'CityShape'

  scope :drivable, -> {where(roadtype: [1,2,3,4,6,7,8,15,17,20])}
  scope :important, -> {where(roadtype: [3,2,6,7])}
  scope :roads, -> {where(roadtype: [3,6,7])}
  scope :disconnected, -> {where('not connected')}
  scope :no_name, -> {where('street_id is null and not validated')}
  scope :without_name, -> {joins('left outer join vw_streets on vw_streets.id = vw_segments.street_id').where('(street_id is null or vw_streets.isempty) and not alt_names')}
  scope :with_speed, -> {where('(not fwddirection or fwdmaxspeed is not null) and (not revdirection or revmaxspeed is not null)')}
  scope :without_speed, -> {where('((fwddirection and fwdmaxspeed is null) or (revdirection and revmaxspeed is null))')}
  scope :no_roundabout, -> {where('roundabout is null or not roundabout')}
  scope :weird_level, -> {where('level < -3 or level > 3')}
  scope :wrong_city, -> {joins([street: :city], :city).where("cities.name <> '' and not (upper(cities.name) = upper(cities_shapes.nm_municip) or upper(cities.name) like '%('||upper(cities_shapes.nm_municip)||')%')")}

  def self.lock_level(max_lock)
    where("lock is null or lock <= ?",max_lock)
  end

#  def self.wrong_city
#    find_by_sql("select vw_segments.* from vw_segments, vw_streets, cities, cities_shapes where vw_segments.street_id = vw_streets.id and vw_streets.city_id = cities.id and vw_segments.city_id = cities_shapes.gid and cities.name <> '' and upper(cities.name) <> upper(cities_shapes.nm_municip)")
#  end

  def location
    "#{((street_id.nil? or street.nil?) ? I18n.t('noname') : ((street.name.nil? or street.name.empty?) ? I18n.t('no-street') : street.name.to_s) + ', ' + ((street.city_id.nil? or street.city.nil?) ? I18n.t('no-city') : ((street.city.name.nil? or street.city.name.empty?) ? I18n.t('no-city') : street.city.name.to_s) + ', ' + ((street.city.state_id.nil? or street.city.state.name.empty?) ? I18n.t('no-state') : street.city.state.name.to_s)))}"
  end
end
