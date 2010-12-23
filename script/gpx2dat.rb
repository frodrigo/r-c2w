
#<gpx>
# <trk>
#  <trkseg>
#   <trkpt lat="44.838739000" lon="0.222790000"/>
#   <trkpt lat="44.838558000" lon="0.222708000"/>

require 'rexml/document'

include REXML
file = File.new(ARGV[0])
doc = Document.new(file)

ways = []
XPath.each(doc, 'gpx/trk/trkseg' ) { |trkseg|
  way = []
  XPath.each(trkseg, 'trkpt' ) { |pt|
    way << [pt.attribute('lat').value,pt.attribute('lon').value]
  }
  ways << way
}

max = ways.to_a.max{ |a,b| a.size <=> b.size }
puts max.size
max.each{ |node|
  puts " #{node[0]} #{node[1]}"
}
puts ''

puts ways.size-1
puts ''

ways.each{ |nodes|
  if nodes != max
    puts nodes.size
    nodes.each{ |node|
      puts " #{node[0]} #{node[1]}"
    }
    puts ''
  end
}
