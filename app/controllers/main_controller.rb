class MainController < ApplicationController

  def index
    @areas = Area.mapraid
    @nav = [{ t('nav-first-page') => '/'}]
  end
  
  def segments
    @area = CityMapraid.find(params['id'])
    @update = Update.find('segments')
    @nav = [{@area.name => "/segments/#{@area.gid}"},{ t('nav-first-page') => '/'}]
  end

  def segments_area
    @area = Area.find(params['id'])
    @update = Update.find('segments')
    @nav = [{@area.name => '#'},{ t('nav-first-page') => '/'}]
    render :segments
  end
end
