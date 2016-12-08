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

  def search
  #  @search = Search.new
    @segments = nil
    if not params['name'].nil?
      if not params['name'].empty?
        @segments = Segment.joins(:street).where("upper(vw_streets.name) like '%#{params['name'].upcase}%'")
      end
    end
    @params = params
    @states = StateShape.all
    @nav = [{'Search' => "#"},{ t('nav-first-page') => '/'}]
  end

  def places
    @user = User.find_by(username: params['id'])
    @update = Update.find('places')
    if @user = nil
      @places = nil
    else
      @places = Place.where('created_by = ? or updated_by = ?',@user.id, @user.id)
    end
    @nav = [{'Places' => '#'},{ t('nav-first-page') => '/'}]
  end

  def editors
    @editors = User.find_by_sql('select users.id, users.username, users.rank, e.last_edit from users, (select distinct last_edit_by as id, max(last_edit_on) as last_edit from segments where city_id is not null group by last_edit_by) as e where e.id = users.id and e.id > 0 and char_length(trim(both from users.username)) > 1 order by users.username')
    @update = Update.maximum(:updated_at)
    @nav = [{'Lista de editores' => '#'},{ t('nav-first-page') => '/'}]
  end

  def editors_list
    @editors = User.find_by_sql('select users.id, users.username, users.rank, e.last_edit from users, (select distinct last_edit_by as id, max(last_edit_on) as last_edit from segments where city_id is not null group by last_edit_by) as e where e.id = users.id and e.id > 0 and char_length(trim(both from users.username)) > 1 order by users.username')
    @update = Update.maximum(:updated_at)
    @nav = [{'Lista de editores' => '#'},{ t('nav-first-page') => '/'}]

    render layout: false
  end
end
