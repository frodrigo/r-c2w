require 'rexml/document'

include REXML
file = File.new(ARGV[0])
doc = Document.new(file)

nodes = {}
XPath.each(doc, 'osm/node' ) { |node|
#  <node id='-5462' timestamp='2010-11-27T20:05:07Z' visible='true' lat='44.839951' lon='0.220289' />
  nodes[Integer(node.attribute('id').value)] = [node.attribute('lat').value,node.attribute('lon').value]
}

ways = {}
XPath.each(doc, 'osm/way' ) { |way|
  refs = []
  XPath.each(way, 'nd/@ref') { |ref|
    refs << Integer(ref.value)
  }
  ways[Integer(way.attribute('id').value)] = refs
}

innerways = []
relations = Hash.new{ |h,k| h[k] = [] }
XPath.each(doc, 'osm/relation' ) { |rel|
  refs = []
  XPath.each(rel, 'member[@type="way"][@role="outer"]/@ref') { |ref|
#    <member type='way' ref='-12770' role='outer' />
    refs << Integer(ref.value)
  }
  relations[rel.attribute('id').value][0] = refs

  refs = []
  XPath.each(rel, 'member[@type="way"][@role="inner"]/@ref') { |ref|
#    <member type='way' ref='-12770' role='inner' />
    refs << Integer(ref.value)
    innerways << Integer(ref.value)
  }
  relations[rel.attribute('id').value][1] = refs
}

puts ways.size
puts

ways.each{ |id,refs|
  if not innerways.include?(id)
    puts refs.size
    puts "0"
    refs.each{ |node|
      puts " #{nodes[node][0]} #{nodes[node][1]}"
    }
    puts
  end
}

relations.each { |id,wayRefs|
  wayRefs[1].each{ |wayRef|
    puts wayRef.size
    puts "1"
    ways[wayRef].each{ |node|
      puts " #{nodes[node][0]} #{nodes[node][1]}"
    }
    puts
  }
}
