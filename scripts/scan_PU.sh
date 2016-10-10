#!/bin/bash

cd /home/rails/segments/scripts

echo "Start: $(date '+%d/%m/%Y %H:%M:%S')"
psql -h $POSTGRESQL_DB_HOST -d $POSTGRESQL_DB_NAME -U $POSTGRESQL_DB_USERNAME -c 'delete from pu;'
psql -h $POSTGRESQL_DB_HOST -d $POSTGRESQL_DB_NAME -U $POSTGRESQL_DB_USERNAME -c 'delete from places;'
psql -h $POSTGRESQL_DB_HOST -d $POSTGRESQL_DB_NAME -U $POSTGRESQL_DB_USERNAME -c 'vacuum pu;'
psql -h $POSTGRESQL_DB_HOST -d $POSTGRESQL_DB_NAME -U $POSTGRESQL_DB_USERNAME -c 'vacuum places;'

# SC
ruby scan_PU.rb $1 $2 -50.61 -25.95 -50.43 -26.04 0.03
ruby scan_PU.rb $1 $2 -50.34 -25.95 -49.8 -26.04 0.03
ruby scan_PU.rb $1 $2 -49.26 -25.95 -48.54 -26.04 0.03
ruby scan_PU.rb $1 $2 -50.7 -26.04 -49.71 -26.13 0.03
ruby scan_PU.rb $1 $2 -49.35 -26.04 -48.54 -26.13 0.03
ruby scan_PU.rb $1 $2 -50.79 -26.13 -48.45 -26.22 0.03
ruby scan_PU.rb $1 $2 -53.67 -26.22 -53.22 -26.31 0.03
ruby scan_PU.rb $1 $2 -51.24 -26.22 -48.45 -26.31 0.03
ruby scan_PU.rb $1 $2 -53.76 -26.31 -52.5 -26.4 0.03
ruby scan_PU.rb $1 $2 -51.33 -26.31 -48.45 -26.4 0.03
ruby scan_PU.rb $1 $2 -53.76 -26.4 -52.05 -26.49 0.03
ruby scan_PU.rb $1 $2 -51.33 -26.4 -48.54 -26.49 0.03
ruby scan_PU.rb $1 $2 -53.76 -26.49 -51.6 -26.58 0.03
ruby scan_PU.rb $1 $2 -51.33 -26.49 -48.54 -26.58 0.03
ruby scan_PU.rb $1 $2 -53.76 -26.58 -48.63 -26.67 0.03
ruby scan_PU.rb $1 $2 -53.76 -26.67 -48.54 -26.76 0.03
ruby scan_PU.rb $1 $2 -53.76 -26.76 -48.54 -26.85 0.03
ruby scan_PU.rb $1 $2 -53.76 -26.85 -48.54 -26.94 0.03
ruby scan_PU.rb $1 $2 -53.85 -26.94 -48.45 -27.03 0.03
ruby scan_PU.rb $1 $2 -53.85 -27.03 -48.45 -27.12 0.03
ruby scan_PU.rb $1 $2 -53.85 -27.12 -48.45 -27.21 0.03
ruby scan_PU.rb $1 $2 -53.67 -27.21 -53.58 -27.3 0.03
ruby scan_PU.rb $1 $2 -53.4 -27.21 -53.22 -27.3 0.03
ruby scan_PU.rb $1 $2 -53.04 -27.21 -52.95 -27.3 0.03
ruby scan_PU.rb $1 $2 -52.86 -27.21 -48.27 -27.3 0.03
ruby scan_PU.rb $1 $2 -52.41 -27.3 -48.36 -27.39 0.03
ruby scan_PU.rb $1 $2 -52.05 -27.39 -48.27 -27.48 0.03
ruby scan_PU.rb $1 $2 -51.96 -27.48 -48.27 -27.57 0.03
ruby scan_PU.rb $1 $2 -51.6 -27.57 -48.36 -27.66 0.03
ruby scan_PU.rb $1 $2 -51.42 -27.66 -48.45 -27.75 0.03
ruby scan_PU.rb $1 $2 -51.33 -27.75 -48.45 -27.84 0.03
ruby scan_PU.rb $1 $2 -51.15 -27.84 -48.45 -27.93 0.03
ruby scan_PU.rb $1 $2 -51.06 -27.93 -48.54 -28.02 0.03
ruby scan_PU.rb $1 $2 -50.97 -28.02 -48.54 -28.11 0.03
ruby scan_PU.rb $1 $2 -50.88 -28.11 -48.63 -28.2 0.03
ruby scan_PU.rb $1 $2 -50.79 -28.2 -48.63 -28.29 0.03
ruby scan_PU.rb $1 $2 -50.7 -28.29 -48.54 -28.38 0.03
ruby scan_PU.rb $1 $2 -50.7 -28.38 -48.63 -28.47 0.03
ruby scan_PU.rb $1 $2 -50.25 -28.47 -48.72 -28.56 0.03
ruby scan_PU.rb $1 $2 -49.89 -28.56 -48.72 -28.65 0.03
ruby scan_PU.rb $1 $2 -49.98 -28.65 -48.9 -28.74 0.03
ruby scan_PU.rb $1 $2 -49.98 -28.74 -49.08 -28.83 0.03
ruby scan_PU.rb $1 $2 -49.98 -28.83 -49.17 -28.92 0.03
ruby scan_PU.rb $1 $2 -49.98 -28.92 -49.26 -29.01 0.03
ruby scan_PU.rb $1 $2 -50.07 -29.01 -49.35 -29.1 0.03
ruby scan_PU.rb $1 $2 -50.16 -29.1 -49.44 -29.19 0.03
ruby scan_PU.rb $1 $2 -50.25 -29.19 -49.53 -29.28 0.03
ruby scan_PU.rb $1 $2 -50.16 -29.28 -49.98 -29.37 0.03
ruby scan_PU.rb $1 $2 -49.89 -29.28 -49.62 -29.37 0.03

psql -h $POSTGRESQL_DB_HOST -d $POSTGRESQL_DB_NAME -U $POSTGRESQL_DB_USERNAME -c 'update places set city_id = (select gid from cities_shapes where ST_Contains(geom, places.position) limit 1) where city_id is null;'
psql -h $POSTGRESQL_DB_HOST -d $POSTGRESQL_DB_NAME -U $POSTGRESQL_DB_USERNAME -c 'delete from places where city_id is null;'
psql -h $POSTGRESQL_DB_HOST -d $POSTGRESQL_DB_NAME -U $POSTGRESQL_DB_USERNAME -c 'refresh materialized view vw_places;'
psql -h $POSTGRESQL_DB_HOST -d $POSTGRESQL_DB_NAME -U $POSTGRESQL_DB_USERNAME -c "update updates set updated_at = current_timestamp where object = 'places';"
psql -h $POSTGRESQL_DB_HOST -d $POSTGRESQL_DB_NAME -U $POSTGRESQL_DB_USERNAME -c 'vacuum places;'

echo "End: $(date '+%d/%m/%Y %H:%M:%S')"
