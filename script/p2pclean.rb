
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
    way << c
  end
}
ways[way] = hole if way


ways2 = {}
ways.each{ |nodes, hole|
  ret = []
  # Clean nodes
  0.upto(nodes.size-1).each{ |i|
    if not ret.include?(nodes[i])
      ret << nodes[i]
    end
  }
  ways2[ret] = hole
}
ways = ways2.select{ |nodes,hole|
  nodes.size > 3
}


puts ways.size

ways.each{ |nodes, hole|
  puts hole
  puts nodes.size
  nodes.each{ |node|
    puts "#{node[0]} #{node[1]}"
  }
}
