#!/bin/sh

QADASTRE=../frodrigo-qadastre2osm/Qadastre2OSM

cat list | while read i; do
    BASE=${i// \"/-}
    BASE=${BASE//\"/}
    echo $i
    if [[ ! -e "${BASE}.pdf" ]]
    then
      echo $i | xargs $QADASTRE --download 011
      echo $i | xargs $QADASTRE --convert-with-lands
    fi
    ./r-c2w.sh "$BASE"
done
