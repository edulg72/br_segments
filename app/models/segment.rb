class Segment < ActiveRecord::Base
  self.table_name = 'vw_segments'
  self.primary_key = 'id'

  belongs_to :editor, foreign_key: 'last_edit_by', class_name: 'User'
  belongs_to :street
  belongs_to :city, foreign_key: 'city_id', class_name: 'CityShape'
  belongs_to :state, foreign_key: 'state_id', class_name: 'StateShape'

  scope :drivable, -> {where(roadtype: [1,2,3,4,6,7,8,15,17,20])}
  scope :important, -> {where(roadtype: [3,2,6,7])}
  scope :roads, -> {where(roadtype: [3,6,7])}
  scope :disconnected, -> {where('not connected')}
  scope :no_name, -> {where('street_id is null and not validated')}
  scope :without_name, -> {joins('left outer join vw_streets on vw_streets.id = vw_segments.street_id').where('(street_id is null or vw_streets.isempty) and not alt_names')}
  scope :with_speed, -> {where('(not fwddirection or fwdmaxspeed is not null) and (not revdirection or revmaxspeed is not null)')}
  scope :without_speed, -> {where('((fwddirection and fwdmaxspeed is null) or (revdirection and revmaxspeed is null))')}
  scope :wrong_speed, -> {joins(:street).where("vw_streets.name !~* '^[[:alpha:]]{2,3}-[[:digit:]]{3}.*' and ((fwddirection and fwdmaxspeed > 70) or (revdirection and revmaxspeed > 70))")}
  scope :no_roundabout, -> {where('roundabout is null or not roundabout')}
  scope :weird_level, -> {where('level < -3 or level > 3')}
  scope :wrong_city, -> {joins([street: :city], :city).where("cities.name <> '' and not (upper(cities.name) = upper(cities_shapes.nm_municip) or upper(cities.name) like '%('||upper(cities_shapes.nm_municip)||')%')")}
  scope :long_streets, -> {where('roadtype = 1 and length > 1500')}
  scope :toll, -> {where(toll: true)}
  scope :low_lock, -> {where('roadtype in (3,6,7) and lock < 3')}
  scope :named_parking, -> {joins(:street).where('roadtype = 20 and not vw_streets.isempty')}

  def self.lock_level(max_lock)
    where("lock is null or lock <= ?",max_lock)
  end

#  def self.wrong_city
#    find_by_sql("select vw_segments.* from vw_segments, vw_streets, cities, cities_shapes where vw_segments.street_id = vw_streets.id and vw_streets.city_id = cities.id and vw_segments.city_id = cities_shapes.gid and cities.name <> '' and upper(cities.name) <> upper(cities_shapes.nm_municip)")
#  end

  def location
    "#{((street_id.nil? or street.nil?) ? I18n.t('noname') : (street.isempty? ? I18n.t('no-street') : street.name.to_s) + ', ' + (street.city_id.nil? ? I18n.t('no-city') : (street.city_isempty? ? I18n.t('no-city') : street.city_name.to_s) + ', ' + ((street.state_id.nil? or street.state_name.empty?) ? I18n.t('no-state') : street.state_name.to_s)))}"
  end
end
