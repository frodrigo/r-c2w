
#3
#0
#63
# 0.216376000000000  44.839097000000002
# 0.216389000000000  44.839047000000001

ways = {}
wid = nil
hole_line=true
first=true

way = nil
hole = nil
STDIN.each{ |line|
  c = line.strip.split(/ +/)
  if c.size == 1
    if first
      first = false
    elsif hole_line
      ways[way] = hole if way
      way = []
      hole = c[0][0]
      hole_line = false
    else
      hole_line = true
    end
  else
    way << [Float(c[0]),Float(c[1])]
  end
}
ways[way] = hole if way


# Node unicity
ways2 = {}
ways.each{ |nodes, hole|
  ret = nodes.uniq
  ways2[ret] = hole
}
# Remove triangle, remove in fact small artefact like very tin gaps between poly
ways = ways2.select{ |nodes,hole|
  nodes.size > 3
}
# Remove small poly, like artefect and swimming pool or realy small lands
ways.select!{ |nodes,hole|
  (x_min,y_min) = nodes[0]
  (x_max,y_max) = nodes[0]
  nodes.each{ |n|
    x_min = x_min < n[0] ? x_min : n[0]
    y_min = y_min < n[1] ? y_min : n[1]
    x_max = x_max > n[0] ? x_max : n[0]
    y_max = y_max > n[1] ? y_max : n[1]
  }
  (x_max-x_min) > 1e-4 or (y_max-y_min) > 1e-4
}


puts ways.size

ways.each{ |nodes, hole|
  puts hole
  puts nodes.size
  nodes.each{ |node|
    puts "#{node[0]} #{node[1]}"
  }
}
