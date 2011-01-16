
.PRECIOUS : %.p %.gpx

RUBY=ruby

%.p: %.osm script/osm2p.rb
	$(RUBY) script/osm2p.rb "$<" > "$@"

%-lands.union.p: %-lands.p %-water.p convo/poly script/p2pclean.rb
	./convo/poly union "$*-lands.p" "$*-water.p" "$*-lands.union.tmp"
	$(RUBY) script/p2pclean.rb < "$*-lands.union.tmp" > "$*-lands.union.p"

%-lands.area.p: %-lands.union.p %-city-limit.p convo/poly script/p2pclean.rb
	./convo/poly diff "$*-city-limit.p" "$*-lands.union.p" "$@.tmp"
	$(RUBY) script/p2pclean.rb < "$@.tmp" > "$@"

%-water.area.p: %-water.p convo/poly script/p2pclean.rb
	./convo/poly union "$<" "$<" "$@.tmp"
	$(RUBY) script/p2pclean.rb < "$@.tmp" > "$@"

%.skel.gpx: %.area.simpl.p skeleton/vononoi-skeleton
	./skeleton/vononoi-skeleton "$<" > "$@"

%-lands.skel-clean.gpx: %-lands.skel.gpx script/rework-gpx.rb
	$(RUBY) script/rework-gpx.rb "$<" > "$@"

%-water.skel-clean.gpx: %-water.skel.gpx script/rework-gpx.rb
	$(RUBY) script/rework-gpx.rb "$<" water > "$@"


# Simplify .p
%.union.gpx: %.union.p script/p2gpx.rb
	$(RUBY) script/p2gpx.rb < "$<" > "$@"
%.area.gpx: %.area.p script/p2gpx.rb
	$(RUBY) script/p2gpx.rb < "$<" > "$@"

%.simpl.gpx: %.gpx
	gpsbabel -i gpx -f "$<" -x simplify,error=0.001k -o gpx -F "$@"

%.simpl.p: %.simpl.gpx script/gpx2p.rb
	$(RUBY) script/gpx2p.rb "$<" > "$@"

convo/poly convo/convo skeleton/vononoi-skeleton:
	@echo Build $@ first
	@exit 1
