#!/bin/sh

DEP=$1
DB=
PSQL="psql $DB"
RUBY=ruby

# Create schema
$PSQL -f stats/gpx-create-table-rc2w.sql

find -name "0${DEP}*.gpx" | sort | while read gpx; do
  echo "${gpx}"
  $RUBY stats/gpx2sql.rb "${gpx}" | $PSQL
done

sed "s/__DEP__/${DEP}/g"  stats/gpx-stats.sql | $PSQL | sed -e 1d -e 2d > cadastre-stats-${DEP}.csv
