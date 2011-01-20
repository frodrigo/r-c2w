#!/bin/sh

PSQL=psql
RUBY=ruby

# Create schema
$PSQL -f stats/create-table-rc2w.sql

find -name '*.gpx' | sort | while read gpx; do
  echo "${gpx}"
  $RUBY stats/gpx2sql.rb "${gpx}" | $PSQL
done

$PSQL -f stats/stats.sql > stats.csv
