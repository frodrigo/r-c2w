
%.p: %.osm script/osm2p.rb
	@echo "osm2p $< -> $@"
	ruby script/osm2p.rb "$<" > "$@"

%-lands.area.p: %-lands.p %-water.p %-city-limit.p poly/poly
	@echo ">> union $^ -> $@"
	./poly/poly union "$*-lands.p" "$*-water.p" "$*-lands.union.p"
	./poly/poly diff "$*-city-limit.p" "$*-lands.union.p" "$@"

%-water.area.p: %-water.p poly/poly
	@echo ">> union $< -> $@"
	./poly/poly union "$<" "$<" "$@"

%.area.gpx: %.area.p script/p2gpx.rb
	@echo "p2gpx $< -> $@"
	ruby script/p2gpx.rb < "$<" > "$@"

%.area-simpl.gpx: %.area.gpx
	@echo ">> simplify $< -> $@"
	gpsbabel -i gpx -f "$<" -x simplify,error=0.001k -o gpx -F "$@"

%.dat: %.area-simpl.gpx script/gpx2dat.rb
	@echo "gpx2dat $< -> $@"
	ruby script/gpx2dat.rb "$<" > "$@"

%.skel.gpx: %.dat skeleton/vononoi-skeleton
	@echo ">> skeleton $< -> $@"
	./skeleton/vononoi-skeleton "$<" > "$@"

%.skel-clean.gpx: %.skel.gpx script/rework-gpx.rb
	@echo ">> rework skeleton $< -> $@"
	ruby script/rework-gpx.rb "$<" > "$@"
