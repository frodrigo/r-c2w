
#3
#0
#63
# 0.216376000000000  44.839097000000002
# 0.216389000000000  44.839047000000001

nodes = {}
ways = {}
holes = {}
id = -1
wid = nil
hole_line=true
first=true

STDIN.each{ |line|
  c = line.strip.split(/ +/)
  if c.size == 1
    if first
      first = false
    elsif hole_line
      wid = (id-=1)
      ways[wid] = []
      holes[wid] = c[0][0]
      hole_line = false
    else
      hole_line = true
    end
  else
    nid = (id-=1)
    nodes[nid] = c
    ways[wid] << nid
  end
}


ways.select!{ |id,nodesRefs|
  nodesRefs.size > 3
}


puts ways.size

ways.each{ |id,refs|
  puts "0"
  puts refs.size
  refs.each{ |node|
    puts "#{nodes[node][0]} #{nodes[node][1]}"
  }
}
