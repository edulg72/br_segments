#!/usr/bin/ruby
# encoding: utf-8
#
# lock_places.rb
# Aplica um determinado lock mínimo nos places de uma região.
# (c)2016 Eduardo Garcia <edulg72@gmail.com>
#
# Usage:
# lock_places.rb <usuario> <senha> <estado> <lock>
#

require 'mechanize'
require 'pg'
require 'json'
require 'net/http'

if ARGV.size < 7
  puts "Usage: ruby lock_places.rb <user> <password> <state> <minimum lock>"
  exit
end

USER = ARGV[0]
PASS = ARGV[1]
State = ARGV[2].to_f
Lock = (ARGV[3].to_i)
Passo = 0.09
#MaxSave = 50  # Maximo de segmentos alterados por vez

agent = Mechanize.new
agent.user_agent_alias = 'Mac Firefox'
begin
  page = agent.get "https://www.waze.com/row-Descartes-live/app/Session"
rescue Mechanize::ResponseCodeError
  @csrf_token = agent.cookie_jar.jar['www.waze.com']['/']['_csrf_token'].value
end

login = agent.post('https://www.waze.com/login/create', {"user_id" => USER, "password" => PASS}, {"X-CSRF-Token" => @csrf_token})
@cookies = login['set-cookie']

db = PG::Connection.new(:hostaddr => '127.0.0.1', :dbname => 'wazedb', :user => 'waze', :password => 'waze')

places = db.exec("select id, name, latitude, longitude from vw_places where city_id in (select gid from cities_shapes where state_id = (select cd_geocuf from states_shapes where abbreviation = '#{State}')) and lock < #{Lock}")

places_updated = 0
places.each do |place|
  ps = {'actions' => {"name" => "CompositeAction", "_subActions" => [{"name" => "MultiAction", "_subActions" => []}]}}
  ps['actions']['_subActions'][0]['_subActions'] << {'_objectType' => 'venue', 'action' => 'UPDATE', 'attributes' => {'lockRank' => (Lock - 1), 'id' => place['id']}}

  headers = {'Content-Type' => 'application/json', 'Accept' => 'application/json', 'Cookie' => @cookies, 'X-CSRF-Token' => @csrf_token}

  begin
    print "=> #{place['name'].nil? ? '[Sem nome]' : place['name']} "
    r = agent.post("https://www.waze.com/row-Descartes-live/app/Features?language=pt-BR&bbox=#{area.join('%2C')}",ps.to_json,headers)

#    uri = URI.parse("https://www.waze.com/row-Descartes-live/app/Features")
#    http = Net::HTTP.new(uri.host, uri.port)
#    http.use_ssl = true
#    r = http.post(uri.path, segs.to_json, headers)

#    puts "Response #{r.code} #{r.message}: #{r.body}"

    response = JSON.parse(r.body)

    if response['synced']
      puts " Ok!"
      places_updated += 1
    end
  rescue Exception => e
    puts "Erro salvando alteracoes"
    puts e.message
    puts e.backtrace.inspect
  end
end

puts "Locked #{places_updated} places!"
