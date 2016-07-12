#!/bin/bash

echo "Start: $(date '+%d/%m/%Y %H:%M:%S')" > /home/rails/scan_Brasil.log

for estado in AC AL AM AP BA CE DF ES GO MA MG MS MT PA PB PE PI PR RJ RN RO RR RS SC SE SP TO
do
  echo "  $estado: $(date '+%d/%m/%Y %H:%M:%S')" >> /home/rails/scan_Brasil.log
  /home/rails/segments/scripts/scan_segments.sh $1 $2 $estado > /home/rails/scan_$estado.log
done

psql -h 127.0.0.1 -d wazedb -U waze < /home/rails/segments/scripts/atualiza_historico.sql

echo "End: $(date '+%d/%m/%Y %H:%M:%S')" >> /home/rails/scan_Brasil.log
