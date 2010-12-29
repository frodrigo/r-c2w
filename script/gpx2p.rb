
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
hole = {}
XPath.each(doc, 'gpx/trk/trkseg' ) { |trkseg|
  way = []
  XPath.each(trkseg, 'trkpt' ) { |pt|
    way << [pt.attribute('lat').value,pt.attribute('lon').value]
  }
  is_hole = XPath.first(trkseg, 'trkpt/extensions')
  if is_hole
    is_hole = is_hole.text
  else
    is_hole = '0'
  end
  hole[way] = is_hole
  ways << way
}

ways = ways.collect{ |nodes|
  ret = []
  # Clean equals consecutive nodes
  0.upto(nodes.size-1).each{ |i|
    if nodes[i] != ret[-1]
      ret << nodes[i]
    end
  }
  # Clean same ends nodes
  ret = if ret[0] == ret[-1]
    ret[0..-2]
  else
    ret
  end
  hole[ret] = hole[nodes]
  ret
}.select{ |nodes| nodes.size >= 3 }

puts ways.size

ways.each{ |nodes|
  puts hole[nodes]
  puts nodes.size
  nodes.each{ |node|
    puts "#{node[0]} #{node[1]}"
  }
}
