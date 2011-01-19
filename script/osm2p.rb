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

relationways = []
relations = Hash.new{ |h,k| h[k] = [] }
XPath.each(doc, 'osm/relation' ) { |rel|
  refs = []
  XPath.each(rel, 'member[@type="way"][@role="outer"]/@ref') { |ref|
#    <member type='way' ref='-12770' role='outer' />
    refs << Integer(ref.value)
    relationways << Integer(ref.value)
  }
  relations[rel.attribute('id').value][0] = refs

  refs = []
  XPath.each(rel, 'member[@type="way"][@role="inner"]/@ref') { |ref|
#    <member type='way' ref='-12770' role='inner' />
    refs << Integer(ref.value)
    relationways << Integer(ref.value)
  }
  relations[rel.attribute('id').value][1] = refs
}


puts ways.size

relations.each{ |id,wayRefs|
  # Deals only with one outter
  outter = ways[wayRefs[0][0]]
  puts "0"
  puts outter.size
  outter.each{ |node|
    puts "#{nodes[node][0]} #{nodes[node][1]}"
  }
  wayRefs[1].each{ |wayRef|
    inner = ways[wayRef]
    puts "1"
    puts inner.size
    inner.each{ |node|
      puts " #{nodes[node][0]} #{nodes[node][1]}"
    }
  }
}

ways.each{ |id, nds|
  if not relationways.include?(id) then
    puts "0"
    puts nds.size
    nds.each{ |node|
      puts "#{nodes[node][0]} #{nodes[node][1]}"
    }
  end
}
