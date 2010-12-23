require 'rexml/document'
include REXML
require 'tools/kdtree.rb'

class P2 < Array
    def initialize(*a)
        self.replace(a)
    end

    def to_s
        "{#{self[0]}, #{self[1]}}"
    end

    def dist(p)
        Math.sqrt( (self[0]-p[0])*(self[0]-p[0]) + (self[1]-p[1])*(self[1]-p[1]) )
    end

    def ==(p)
        p != nil and self[0] == p[0] and self[1] == p[1]
    end
end

class KDTree
    attr_accessor :black_list

    def getInBox(p, e)
        find([p[0]-e,p[0]+e], [p[1]-e,p[1]+e])
    end

    def nearest(p, e)
        r = getInBox(p, e).sort!{ |p1,p2|
            p.dist(p1) <=> p.dist(p2)
        }.select{ |pp|
            p != pp
        }
        r0 = r.select{ |pp|
            p[2] != pp[2] and not self.black_list.include?(pp)
        }
        return nil if r0 == [] or (p[0]==r0[0] and p[1] ==r0[1]) # il n'y a pas de gap
        if r[r.index(r0[0])..r.rindex(r0[0])].all?{ |pp| # verif que tous les points le plus proche ne sont pas sur la way de p
            p[2] != pp[2]
        } then
            r0[0]
        end
    end
end


# --------- Main

file = File.new(ARGV[0])
doc = Document.new(file)

@ways = []
XPath.each(doc, 'gpx/trk/trkseg' ) { |trkseg|
  way = []
  XPath.each(trkseg, 'trkpt' ) { |pt|
    way << P2.new(Float(pt.attribute('lat').value),Float(pt.attribute('lon').value))
  }
  @ways << way
}




# Construit les linestring
@ends = Hash.new{ |h,k| h[k] = [] }

@ways_ends = {}
@ways.each{ |w|
  @ends[w[0]] << w
  @ends[w[-1]] << w
  @ways_ends[w] = [@ends[w[0]], @ends[w[-1]]]
}

def merge_linestring
  begin
  touch = false
  STDERR.puts @ways.size
  @ends.select{ |k,v| v.size == 2 }.each{ |k,e|
    w1 = e[0]
    w2 = e[1]
    if w1[-1] == w2[0]
      w = w1+w2
    elsif w1[-1] == w2[-1]
      w = w1+w2.reverse
    elsif w1[0] == w2[0]
      w = w1.reverse+w2
    elsif w1[0] == w2[-1]
      w = w2+w1
    else
      raise 'fail!'
    end
    @ends[w[0]] << w
    @ends[w[-1]] << w
    @ways_ends[w] = [@ends[w[0]], @ends[w[-1]]]
    @ways << w

    @ways_ends[w1][0].delete(w1)
    @ways_ends[w1][1].delete(w1)
    @ways_ends[w2][0].delete(w2)
    @ways_ends[w2][1].delete(w2)
    @ends.delete(k)
    @ways.delete(w1)
    @ways.delete(w2)
    touch = true
  }
  end while touch
  STDERR.puts @ways.size
end

merge_linestring


# Comble des petits vides entres les ways
points = []
@ways.each{ |way|
  points << way[0] + [way]
  points << way[-1] + [way]
}

kdtree = KDTree.new(points, 2)
kdtree.black_list = []

@ends.select{ |k,v| v.size == 1 }.each{ |k,e|
  n = kdtree.nearest(k, 5e-6)
  if n
    way = [k,n[0..1]]
    @ways << way
    kdtree.black_list << k
    @ends[k] << way
    @ends[n] << way
    @ways_ends[way] = [k,n]
  end
}

merge_linestring

# Prune
@ends.select{ |k,v| v.size == 1 }.each{ |k,w|
  way = w[0]
  if way
#    con = (w[0] == k)? w[-1] : w[0]
    l = 0
    0.upto(way.size-2).each{ |i| l+= Math.sqrt( (way[i][0]-way[i+1][0])*(way[i][0]-way[i+1][0]) + (way[i][1]-way[i+1][1])*(way[i][1]-way[i+1][1]) ) }
    if l < 2e-4 # FIXME marche pour la Fance metrop
      @ends.delete(k)
      #@ways_ends[way][0].delete(way)
      #@ways_ends[way][1].delete(way)
      @ways.delete(way)
    end
  end
}

merge_linestring

# Dump
puts "<gpx><trk>"
@ways.each{ |way|
  puts "<trkseg>"
  way.each{ |p|
    puts "<trkpt lat='#{p[0]}' lon='#{p[1]}'/>"
  }
  puts "</trkseg>"
}
puts "</trk></gpx>"
