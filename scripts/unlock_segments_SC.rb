#!/usr/bin/ruby
# encoding: utf-8
#
# scan_segments.rb
# Popula tabelas em uma base PostgreSQL com os dados dos segmentos de uma região.
# (c)2015 Eduardo Garcia <edulg72@gmail.com>
#
# Usage:
# scan_segments.rb <usuario> <senha> <longitude oeste> <latitude norte> <longitude leste> <latitude sul> <passo em graus*>
#
# * Define o tamanho dos quadrados das áreas para análise. Em regiões muito populosas usar valore pequenos para não sobrecarregar o server.

require 'mechanize'
require 'json'

if ARGV.size < 7
  puts "Usage: ruby scan_segments.rb <user> <password> <west longitude> <north latitude> <east longitude> <south latitude> <step>"
  exit
end

USER = ARGV[0]
PASS = ARGV[1]
LongOeste = ARGV[2].to_f
LatNorte = ARGV[3].to_f
LongLeste = ARGV[4].to_f
LatSul = ARGV[5].to_f
Passo = ARGV[6].to_f

puts "Starting analysis on [#{LongOeste} #{LatNorte}] - [#{LongLeste} #{LatSul}]"

agent = Mechanize.new
agent.ignore_bad_chunking = true
begin
  page = agent.get "https://www.waze.com/row-Descartes-live/app/Session"
rescue Mechanize::ResponseCodeError
  @csrf_token = agent.cookie_jar.jar['www.waze.com']['/']['_csrf_token'].value
end
login = agent.post('https://www.waze.com/login/create', {"user_id" => USER, "password" => PASS}, {"X-CSRF-Token" => @csrf_token})
@cookies = login['set-cookie']

@users = {}
@states = {}
@cities = {}
@streets = {}
@segments = {}

def busca(agent,longOeste,latNorte,longLeste,latSul,passo,exec)
  updates = 0
  maxSaves = (rand * 30).to_i + 1

  lonIni = longOeste
  while lonIni < longLeste do
    lonFim = [(lonIni + passo).round(13) , longLeste].min
    lonFim = lonIni + passo if (lonFim - lonIni) < (passo / 2)
    latIni = latNorte
    while latIni > latSul do
      latFim = [(latIni - passo).round(13), latSul].max
      latFim = latIni - passo if (latIni - latFim) < (passo / 2)
      area = [lonIni, latIni, lonFim, latFim]

      begin
        puts "#{area}"
        wme = agent.get "https://www.waze.com/row-Descartes-live/app/Features?roadTypes=1%2C2%2C3%2C4%2C5%2C6%2C7%2C8%2C10%2C15%2C16%2C17%2C18%2C19%2C20&zoom=4&bbox=#{area.join('%2C')}"

        json = JSON.parse(wme.body)

        #puts "#{json['segments']['objects']}"
        #exit

        # Get users data
        json['users']['objects'].each {|u| @users[u['id']] = {:username => u['userName'], :rank => u['rank']+1} if not @users.has_key?(u['id']) }

        # Get state names
        json['states']['objects'].each {|s| @states[s['id']] = {:name => s['name'], :countryID => s['countryID']} if not @states.has_key?(s['id']) }

        # Get city names
        json['cities']['objects'].each {|c| @cities[c['id']] = {:name => c['name'], :stateID => c['stateID'], :isEmpty => c['isEmpty']} if not @cities.has_key?(c['id']) }

        # Get street names
        json['streets']['objects'].each {|s| @streets[s['id']] = {:name => s['name'], :cityID => s['cityID'], :isEmpty => s['isEmpty']} if not @streets.has_key?(s['id']) }

        # Get segments data
        json['segments']['objects'].each do |s|
          if @users[s['updatedBy']][:username] == 'edulg' and s['lockRank'] == 2 and [1,2,5,8,10,16,17,20].include?(s['roadType']) and @states[@cities[@streets[s['primaryStreetID']][:cityID]][:stateID]][:name] == 'Santa Catarina'
            @segments[s['id']] = {'_objectType' => 'segment', 'action' => 'UPDATE', 'attributes' => {'lockRank' => nil, 'id' => s['id']}} if not @segments.has_key?(s['id'])
            #puts "Incluido #{s['id']} com tipo #{s['roadType']}, rank #{s['lockRank']}, estado #{@states[@cities[@streets[s['primaryStreetID']][:cityID]][:stateID]][:name]} e alterado por #{@users[s['updatedBy']][:username]}"
            updates += 1
          end

          if updates >= maxSaves
            ps = {'actions' => {"name" => "CompositeAction", "_subActions" => [{"name" => "MultiAction", "_subActions" => []}]}}
            @segments.each_key {|k| ps['actions']['_subActions'][0]['_subActions'] << @segments[k]}

            headers = {'Content-Type' => 'application/json', 'Accept' => 'application/json', 'Cookie' => @cookies, 'X-CSRF-Token' => @csrf_token}

            begin
              print "Atualizando #{@segments.size} segmentos: #{@segments.keys}"
              r = agent.post("https://www.waze.com/row-Descartes-live/app/Features?language=pt-BR&bbox=#{area.join('%2C')}",ps.to_json,headers)
              response = JSON.parse(r.body)

              #if true
              if response['synced']
                puts " Ok!"
                #segments_updated += @segments.size
                @segments = {}
                updates = 0
                maxSaves = (rand * 30).to_i + 1
                sleep (10 * rand).to_i
              end
            rescue Exception => e
              puts "Erro salvando alteracoes"
              puts e.message
              puts e.backtrace.inspect
            end
          end
        end

#      rescue Mechanize::ResponseCodeError, NoMethodError
#        # If issue is related to json package size, divide the area by 4 (limited to 3 divisions)
#        if exec < 1
#          busca(db,agent,area[0],area[1],area[2],area[3],(passo/2),(exec+1))
#        else
#          puts "[#{Time.now.strftime('%d/%m/%Y %H:%M:%S')}] - ResponseCodeError em #{area}"
#        end
      rescue JSON::ParserError
        if exec < 1
          sleep(5)
          busca(db,agent,area[0],area[1],area[2],area[3],passo,(exec+1))
        else
          puts "Erro JSON em #{area}"
        end
      rescue Mechanize::ChunkedTerminationError
        puts "[#{Time.now.strftime('%d/%m/%Y %H:%M:%S')}] - ChunkedTerminationError em #{area}"
      rescue Mechanize::Error
        puts "[#{Time.now.strftime('%d/%m/%Y %H:%M:%S')}] - Error em #{area}"
      end
      sleep 5

      latIni = latFim
    end
    lonIni = lonFim
  end

  if @segments.size > 0
    ps = {'actions' => {"name" => "CompositeAction", "_subActions" => [{"name" => "MultiAction", "_subActions" => []}]}}
    @segments.each_key {|k| ps['actions']['_subActions'][0]['_subActions'] << @segments[k]}

    headers = {'Content-Type' => 'application/json', 'Accept' => 'application/json', 'Cookie' => @cookies, 'X-CSRF-Token' => @csrf_token}

    begin
      print "Atualizando #{@segments.size} segmentos: #{@segments.keys}"
      r = agent.post("https://www.waze.com/row-Descartes-live/app/Features?language=pt-BR&bbox=#{area.join('%2C')}",ps.to_json,headers)
      response = JSON.parse(r.body)

      #if true
      if response['synced']
        puts " Ok!"
        #segments_updated += @segments.size
        @segments = {}
        updates = 0
        maxSaves = (rand * 30).to_i + 1
      end
    rescue Exception => e
      puts "Erro salvando alteracoes"
      puts e.message
      puts e.backtrace.inspect
    end
  end
end

busca(agent,LongOeste,LatNorte,LongLeste,LatSul,Passo,1)
