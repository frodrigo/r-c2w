
#<gpx>
# <trk>
#  <trkseg>
#   <trkpt lat="44.838739000" lon="0.222790000"/>
#   <trkpt lat="44.838558000" lon="0.222708000"/>

require 'rexml/document'

include REXML
name = ARGV[0]
file = File.new(name)
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
puts ways.collect{ |way|
  "INSERT INTO rc2w (geom, name) VALUES ( ST_GeomFromText('LINESTRING(" +
  way.collect{ |n|
    "#{n[1]} #{n[0]}"
  }.join(',') +
  ")', 4326), '#{name}');"
}
