#!/usr/bin/ruby
# encoding: utf-8
#
# scan_UR.rb
# Populates tables on a PostgreSQL database with data from an area.
# (c)2015 Eduardo Garcia <edulg72@gmail.com>
#
# Usage:
# scan_UR.rb <user> <password> <west longitude> <north latitude> <east longitude> <south latitude> <step*>
#
# * Defines the size in degrees (width and height) of the area to be analyzed. On very dense areas use small values to avoid server overload.
#
require 'mechanize'
require 'pg'
require 'json'

if ARGV.size < 7
  puts "Usage: ruby scan_UR.rb <user> <password> <west longitude> <north latitude> <east longitude> <south latitude> <step>"
  exit
end

USER = ARGV[0]
PASS = ARGV[1]
LongWest = ARGV[2].to_f
LatNorth = ARGV[3].to_f
LongEast = ARGV[4].to_f
LatSouth = ARGV[5].to_f
Step = ARGV[6].to_f

agent = Mechanize.new
begin
  page = agent.get "https://www.waze.com/row-Descartes-live/app/Session"
rescue Mechanize::ResponseCodeError
  csrf_token = agent.cookie_jar.jar['www.waze.com']['/']['_csrf_token'].value
end
login = agent.post('https://www.waze.com/login/create', {"user_id" => USER, "password" => PASS}, {"X-CSRF-Token" => csrf_token})

db = PG::Connection.new(:hostaddr => '127.0.0.1', :dbname => 'wazedb', :user => 'waze', :password => 'waze')

@users = {}
@mps = {}
@urs = {}

def scan_UR(db,agent,longWest,latNorth,longEast,latSouth,step,exec)
  lonStart = longWest
  while lonStart < longEast do
    lonEnd = [((lonStart + step)*100000).to_int/100000.0 , longEast].min
    lonEnd = longEast if (longEast - lonEnd) < (step / 4)
    latStart = latNorth
    while latStart > latSouth do
      latEnd = [((latStart - step)*100000).to_int/100000.0, latSouth].max
      latEnd = latSouth if (latEnd - latSouth) < (step / 4)
      area = [lonStart, latStart, lonEnd, latEnd]

      begin
        wme = agent.get "https://www.waze.com/row-Descartes-live/app/Features?mapUpdateRequestFilter=1&problemFilter=0&bbox=#{area.join('%2C')}"

        json = JSON.parse(wme.body)

        # Stores users that edit on this area
        json['users']['objects'].each do |u|
#          puts "#{u['id']},\"#{u['userName'].nil? ? u['userName'] : u['userName'][0..49]}\",#{u['rank']+1}"
          @users[u['id']] = "#{u['id']},\"#{u['userName'].nil? ? u['userName'] : u['userName'][0..49]}\",#{u['rank']+1}\n" if not @users.has_key?(u['id'])
        end

        # Stores MPs data from the area
        json['problems']['objects'].each do |m|
          puts "#{m['id']},#{m['resolvedBy']},#{m['resolvedOn'].nil? ? nil : Time.at(m['resolvedOn']/1000)},#{m['weight']},\"POINT (#{m['geometry']['coordinates'][0]} #{m['geometry']['coordinates'][1]}),4326\",#{m['resolution']}"
          @mps[m['id']] = "#{m['id']},#{m['resolvedBy']},#{m['resolvedOn'].nil? ? nil : Time.at(m['resolvedOn']/1000)},#{m['weight']},\"POINT (#{m['geometry']['coordinates'][0]} #{m['geometry']['coordinates'][1]})\",#{m['resolution']}\n" if not @mps.has_key?(m['id'])
        end

        urs_area = []
        # Search IDs from area  URs
        json['mapUpdateRequests']['objects'].each do |u|
          @urs[u['id']] = "#{u['id']},\"SRID=4326;POINT(#{u['geometry']['coordinates'][0]} #{u['geometry']['coordinates'][1]})\",#{u['resolvedBy']},#{u['resolvedOn'].nil? ? '' : Time.at(u['resolvedOn']/1000)},#{Time.at(u['driveDate']/1000)},#{u['resolution']}" if not @urs.has_key?(u['id'])
          urs_area << u['id']
        end

        # Collect data from URs
        if urs_area.size > 0
          ur = JSON.parse(agent.get("https://www.waze.com/row-Descartes-live/app/MapProblems/UpdateRequests?ids=#{urs_area.join('%2C')}").body)

          ur['updateRequestSessions']['objects'].each do |u|
            @urs[u['id']] += ",#{u.has_key?('comments') and u['comments'].size > 0 ? u['comments'].size : 0},#{u.has_key?('comments') and u['comments'].size > 0 ? '"'+u['comments'][-1]['text'].gsub('"',"'")+'"' : ''},#{u.has_key?('comments') and u['comments'].size > 0 ? Time.at(u['comments'][-1]['createdOn']/1000) : ''},#{u.has_key?('comments') and u['comments'].size > 0 ? u['comments'][-1]['userID'] : ''},#{u.has_key?('comments') and u['comments'].size > 0 ? Time.at(u['comments'][0]['createdOn']/1000) : ''}\n"
            puts @urs[u['id']]
          end
        end

      # Trata eventuais erros de conexao
      rescue Mechanize::ResponseCodeError
        # Caso o problema tenha sido no tamanho do pacote de resposta, divide a area em 4 pedidos menores (limitado a 3 reducoes)
        if exec < 3
          scan_UR(db,agent,area[0],area[1],area[2],area[3],(step/2),(exec+1))
        else
          puts "[#{Time.now.strftime('%d/%m/%Y %H:%M:%S')}] - ResponseCodeError em #{area}"
        end
      rescue JSON::ParserError
        # Erro no corpo do pacote - precisa ser investigada a razao deste erro
        puts "Erro JSON em #{area}"
      end

      latStart = latEnd
    end
    lonStart = lonEnd
  end
end

scan_UR(db,agent,LongWest,LatNorth,LongEast,LatSouth,Step,1)

db.exec("delete from users where id in (#{@users.keys.join(',')})") if @users.size > 0
db.copy_data('COPY users (id,username,rank) FROM STDIN CSV') do
  @users.each_value {|u| db.put_copy_data u}
end
db.exec('vacuum users')

db.exec("delete from mp where id in (#{@mps.keys.join(',')})") if @mps.size > 0
db.copy_data('COPY mp (id,resolved_by,resolved_on,weight,position,resolution) FROM STDIN CSV') do
  @mps.each_value {|m| db.put_copy_data m}
end
db.exec('vacuum mp')

db.exec("delete from ur where id in (#{@urs.keys.join(',')})") if @urs.size > 0
db.copy_data('COPY ur (id,position,resolved_by,resolved_on,created_on,resolution,comments,last_comment,last_comment_on,last_comment_by,first_comment_on) FROM STDIN CSV') do
  @urs.each_value {|u| db.put_copy_data u}
end
db.exec('vacuum ur')
