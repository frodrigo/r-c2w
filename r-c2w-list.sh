#!/bin/bash

QADASTRE=../frodrigo-qadastre2osm/Qadastre2OSM

cat list | while read DEP REF NOM; do
    #040 HA001 "AIRE-SUR-L ADOUR"
    NOM=${NOM//\"/}
    SOURCE="${REF}-${NOM}"
    TARGET="${DEP}-${REF}-${NOM// /_}"
    echo $TARGET
    if [[ ! -e "${TARGET}-lands.osm" ]]; then
      $QADASTRE --download ${DEP} ${REF} "${NOM}"
      mv "${SOURCE}.pdf" "${TARGET}.pdf"
      mv "${SOURCE}.bbox" "${TARGET}.bbox"
      $QADASTRE --convert-with-lands "${DEP}-${REF}" "${NOM// /_}"
    fi
    ./r-c2w.sh "${TARGET}"
done
