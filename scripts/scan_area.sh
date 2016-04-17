#!/bin/bash

ruby scan_segments.rb $1 $2 $3 $4 $5 $6 0.09
psql -h localhost -d wazedb -U waze -c 'update segments set city_id = (select gid from cities_shapes where ST_Contains(geom, ST_SetSRID(ST_Point(segments.longitude, segments.latitude), 4326)) limit 1) where city_id is null;'
psql -h localhost -d wazedb -U waze -c 'delete from segments where city_id is null;'
psql -h localhost -d wazedb -U waze -c 'update segments s1 set dc_density = (select count(*) from segments s2 where not s2.connected and s2.latitude between (s1.latitude - 0.01) and (s1.latitude + 0.01) and s2.longitude between (s1.longitude - 0.01) and (s1.longitude + 0.01)) where not s1.connected and s1.dc_density is null;'
psql -h localhost -d wazedb -U waze -c "update updates set updated_at = current_timestamp where object = '$7';"
psql -h localhost -d wazedb -U waze -c "refresh materialized view vw_segments; refresh materialized view vw_streets;"
