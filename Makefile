
%.p: %.osm script/osm2p.rb
	ruby script/osm2p.rb "$<" > "$@"

%-lands.union.p: %-lands.p %-water.p poly/poly script/p2pclean.rb
	./poly/poly union "$*-lands.p" "$*-water.p" "$*-lands.union.tmp"
	ruby script/p2pclean.rb < "$*-lands.union.tmp" > "$*-lands.union.p"

%-lands.convo.p: %-lands.union.simpl.p convo/convo
	./convo/convo "$<" "$@" 0.0003

%-lands.area.p: %-lands.union.p %-lands.convo.p %-city-limit.p convo/poly convo/convo script/p2pclean.rb
	./convo/poly diff "$*-city-limit.p" "$*-lands.union.p" "$@.tmp1"
	./convo/poly diff "$*-city-limit.p" "$*-lands.convo.p" "$@.tmp2"
	./convo/convo "$@.tmp2" "$@.tmp3" 0.0004
	./convo/poly diff "$@.tmp1" "$@.tmp3" "$@.tmp4"
	ruby script/p2pclean.rb < "$@.tmp4" > "$@"

%-water.area.p: %-water.p poly/poly
	./poly/poly union "$<" "$<" "$@"

%.skel.gpx: %.area.simpl.p skeleton/vononoi-skeleton
	./skeleton/vononoi-skeleton "$<" > "$@"

%.skel-clean.gpx: %.skel.gpx script/rework-gpx.rb
	ruby script/rework-gpx.rb "$<" > "$@"


# Simplify .p
%.union.gpx: %.union.p script/p2gpx.rb
	ruby script/p2gpx.rb < "$<" > "$@"
%.area.gpx: %.area.p script/p2gpx.rb
	ruby script/p2gpx.rb < "$<" > "$@"

%.simpl.gpx: %.gpx
	gpsbabel -i gpx -f "$<" -x simplify,error=0.001k -o gpx -F "$@"

%.simpl.p: %.simpl.gpx script/gpx2p.rb
	ruby script/gpx2p.rb "$<" > "$@"

convo/poly convo/convo skeleton/vononoi-skeleton:
	@echo Build $@ first
	@exit 1
