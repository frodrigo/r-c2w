#!/bin/sh

DEP=$1
PSQL=psql
PGSQL2SHP=pgsql2shp
RUBY=ruby

# Create schema
$PSQL -f stats/osm-create-table-cadastre.sql

# Load stats from cadastre
$PSQL -c "COPY cadastre FROM STDIN WITH CSV HEADER;" < "cadastre-stats-${DEP}.csv"

# Load view
sed -e "s/__DEP__/${DEP}/g" stats/osm-stats-geom.sql | $PSQL


$PSQL -c 'copy (select refINSEE, name, osm_km, cadastre_km, ratio from osm_stats) to stdout with csv header;' > "osm_vs_cadastre-${DEP}.csv"

$PGSQL2SHP -f "osm_vs_cadastre-${DEP}" 'SELECT * FROM osm_stats'
