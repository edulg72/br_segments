class MainController < ApplicationController

  def index
    @segments = Segment.all
    @states = StateShape.all
    @update = Update.maximum('updated_at')
    @nav = [{ t('nav-first-page') => '/'}]
  end

  def segments
    @area = CityShape.find(params['id'])
    @update = Update.find(@area.state.abbreviation)
    @nav = [{@area.name => "#"},{@area.state.nm_estado => "/segments_state/#{@area.state.abbreviation}"},{ t('nav-first-page') => '/'}]
  end

  def segments_state
    @area = StateShape.find_by(abbreviation: params['id'])
    @update = Update.find(params['id'])
    @nav = [{@area.nm_estado => '#'},{ t('nav-first-page') => '/'}]
    render :segments
  end
end
