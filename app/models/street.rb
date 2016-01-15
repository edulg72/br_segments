class Street < ActiveRecord::Base
  self.table_name = 'vw_streets'
  self.primary_key = 'id'
  
  belongs_to :city
  has_many :segments

  def segment_ids
    segs = []
    self.segments.each {|s| segs << s.id}
    segs.join(',')
  end
end
