
#<gpx>
# <trk>
#  <trkseg>
#   <trkpt lat="44.838739000" lon="0.222790000"/>
#   <trkpt lat="44.838558000" lon="0.222708000"/>

require 'rexml/document'

include REXML
full_filename = ARGV[0]

#011-7A001-AIGUES_VIVES-lands.skel-clean.gpx
filename = full_filename.split('/')[-1]
dep = filename[0..2]
ref = filename[6..8]
refINSEE = dep[0] == '0' ? "#{dep[1..2]}#{ref}" : "#{dep[0..2]}#{ref[1..2]}"
type = filename[-20] # [lw]
name = filename[10..-22]


file = File.new(full_filename)
doc = Document.new(file)

ways = []
XPath.each(doc, 'gpx/trk/trkseg' ) { |trkseg|
  way = []
  XPath.each(trkseg, 'trkpt' ) { |pt|
    way << [pt.attribute('lat').value,pt.attribute('lon').value]
  }
  ways << way
}


#INSERT INTO geotable ( the_geom, the_name ) VALUES ( ST_GeomFromText('LINESTRING(0 0,1 1,1 2)', 312), 'A Place');
ways.each{ |way|
  puts "INSERT INTO rc2w (geom, refINSEE) VALUES ( ST_GeomFromText('LINESTRING(" +
  way.collect{ |n|
    "#{n[1]} #{n[0]}"
  }.join(',') +
  ")', 4326), '#{refINSEE}');"
}
