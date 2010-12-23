
#3
#63
# 0.216376000000000  44.839097000000002
# 0.216389000000000  44.839047000000001

nodes = {}
ways = {}
id = -1
wid = nil

STDIN.each{ |line|
  c = line.strip.split(/ +/)
  if c.size == 1
    wid = (id-=1)
    ways[wid] = []
  else
    nid = (id-=1)
    nodes[nid] = c
    ways[wid] << nid
  end
}

ways.select!{ |id,nodesRefs|
  nodesRefs.size > 0
}

puts "<?xml version='1.0' encoding='UTF-8'?>
<gpx><trk>"
ways.each{ |id,nodesRefs|
  puts "<trkseg>"
  nodesRefs.each{ |ref|
    puts "<trkpt lat='#{nodes[ref][0]}' lon='#{nodes[ref][1]}'/>"
  }
  puts "<trkpt lat='#{nodes[nodesRefs[0]][0]}' lon='#{nodes[nodesRefs[0]][1]}'/>"
  puts "</trkseg>"
}
puts "</trk></gpx>"
