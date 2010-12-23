#!/usr/bash

BASE=$1

LAND=${BASE}-lands.osm
WATER=${BASE}-water.osm
BOUNDARY=${BASE}-city-limit.osm

echo ${LAND}
echo ${WATER}
echo ${BOUNDARY}

echo "osm2p"
ruby script/osm2p.rb "${LAND}" > "${LAND}.p"
ruby script/osm2p.rb "${WATER}" > "${WATER}.p"
ruby script/osm2p.rb "${BOUNDARY}" > "${BOUNDARY}.p"

echo ">> union"
./poly/poly union "${LAND}.p" "${WATER}.p" "${LAND}.union.p"
./poly/poly diff "${BOUNDARY}.p" "${LAND}.union.p" "${LAND}.area.p"
./poly/poly union "${WATER}.p" "${WATER}.p" "${WATER}.area.p"

echo "p2gpx"
ruby script/p2gpx.rb < "${LAND}.area.p" > "${LAND}.area.gpx"
ruby script/p2gpx.rb < "${WATER}.area.p" > "${WATER}.area.gpx"

echo ">> simplify"
gpsbabel -i gpx -f "${LAND}.area.gpx" -x simplify,error=0.001k -o gpx -F "${LAND}.area-simpl.gpx"
gpsbabel -i gpx -f "${WATER}.area.gpx" -x simplify,error=0.001k -o gpx -F "${WATER}.area-simpl.gpx"

echo "gpx2dat"
ruby script/gpx2dat.rb "${LAND}.area-simpl.gpx" > "${LAND}.area-simpl.dat"
ruby script/gpx2dat.rb "${WATER}.area-simpl.gpx" > "${WATER}.area-simpl.dat"

echo ">> skeleton"
./skeleton/vononoi-skeleton "${LAND}.area-simpl.dat" > "${LAND}.skel.gpx"
./skeleton/vononoi-skeleton "${WATER}.area-simpl.dat" > "${WATER}.skel.gpx"

ruby script/rework-gpx.rb "${LAND}.skel.gpx" > "${LAND}.skel-clean.gpx"
ruby script/rework-gpx.rb "${WATER}.skel.gpx" > "${WATER}.skel-clean.gpx"
