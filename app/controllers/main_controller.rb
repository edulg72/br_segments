class MainController < ApplicationController

  def index
    @segments = Segment.all
    @states = StateShape.all
    @nav = [{ t('nav-first-page') => '/'}]
  end

  def segments
    @area = CityShape.find(params['id'])
    @update = Update.find(@area.state.abbreviation)
    @nav = [{@area.name => "#"},{@area.state.nm_estado => "/segments_state/#{@area.state.cd_geocuf}"},{ t('nav-first-page') => '/'}]
  end

  def segments_state
    @state = StateShape.find(params['id'])
    @update = Update.find(params['id'])
    @nav = [{@state.nm_estado => '#'},{ t('nav-first-page') => '/'}]
    render :segments
  end
end
