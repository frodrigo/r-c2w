#!/bin/sh

BASE=$1
BASE=${BASE// /\\ }

make "${BASE}-lands.convo.p" # FIXME bug in Makefile deps
make "${BASE}-lands.skel-clean.gpx"
make "${BASE}-water.skel-clean.gpx"
