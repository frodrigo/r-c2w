#!/bin/sh

DB=
PSQL="psql $DB"
RUBY=ruby

# Create schema
$PSQL -f stats/gpx-create-table-rc2w.sql

find . -name "*-lands.skel-clean.gpx" | sort | while read gpx; do
  echo "${gpx}"
  $RUBY stats/gpx2sql.rb "${gpx}" | $PSQL
done

cat stats/gpx-rework.sql | $PSQL

DEP=
sed "s/__DEP__/${DEP}/g" stats/gpx-stats.sql | $PSQL | sed -e 1d -e 2d > cadastre-stats-${DEP}.csv
