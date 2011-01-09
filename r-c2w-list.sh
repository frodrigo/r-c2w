#!/bin/sh

QADASTRE=../frodrigo-qadastre2osm/Qadastre2OSM

cat list | while read i; do
    BASE0=${i// \"/-}
    BASE0=${BASE0//\"/}
    BASE=${BASE0// /_}
    echo $i
    if [[ ! -e "${BASE}.pdf" ]]; then
      echo "${i}" | xargs $QADASTRE --download 011
      echo "${i}" | xargs $QADASTRE --convert-with-lands
      if [[ "$BASE0" != "$BASE" ]]; then
        mv "${BASE0}.pdf" "${BASE}.pdf"
        mv "${BASE0}.bbox" "${BASE}.bbox"
        mv "${BASE0}-cemeteries.osm" "${BASE}-cemeteries.osm"
        mv "${BASE0}-city-limit.osm" "${BASE}-city-limit.osm"
        mv "${BASE0}-houses.osm" "${BASE}-houses.osm"
        mv "${BASE0}-lands.osm" "${BASE}-lands.osm"
        mv "${BASE0}-rails.osm" "${BASE}-rails.osm"
        mv "${BASE0}-water.osm" "${BASE}-water.osm"
      fi
    fi
    ./r-c2w.sh "$BASE"
done
