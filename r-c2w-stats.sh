#!/bin/sh

PSQL=psql

# Create schema
$PSQL -f stats/create-table-rc2w.sql

find -name '*.gpx' | while read gpx; do
  echo "${gpx}"
  ruby stats/gpx2sql.rb "${gpx}" | $PSQL
done

$PSQL -f stats/stats.sql
