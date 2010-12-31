require 'rexml/document'
include REXML
require './script/kdtree.rb'

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
            p[2] != pp[2]
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


def merge_linestring
  begin
  STDERR.puts "#{@ways.size} to merge"
  ends = @ends.select{ |k,v| v.size == 2}
  touch = false
  ends.each{ |k,e|
    w1 = e[0]
    w2 = e[1]
    if w1 == w2
      next
    end

    @ends[w1[0]].delete(w1) or raise 'fail!'
    @ends[w1[-1]].delete(w1) or raise 'fail!'
    @ends[w2[0]].delete(w2) or raise 'fail!'
    @ends[w2[-1]].delete(w2) or raise 'fail!'
    @ends.delete(k) or raise 'fail!'
    @ways.delete(w1) or raise 'fail!'
    @ways.delete(w2) or raise 'fail!'

    if w1[-1] == k
      if w2[0] == k
        w1
        w2
      elsif w2[-1] == k
        w1
        w2 = w2.reverse
      else
        raise 'fail!'
      end
    elsif w1[0] == k
      if w2[0] == k
        w1 = w1.reverse
        w2
      elsif w2[-1] == k
        w1 = w1.reverse
        w2 = w2.reverse
      else
        raise 'fail!'
      end
    else
      raise 'fail!'
    end

    w = w1[0..-2] + w2

    @ends[w[0]] << w
    @ends[w[-1]] << w
    @ways << w
    touch = true
  }
  end while touch
  STDERR.puts "#{@ways.size} result"
end

STDERR.puts "Uniq node per way"
@ways.collect!{ |way|
  ret = []
  way.each{ |w|
    ret << w if not ret.include?(w)
  }
  ret
}

@ways.select!{ |way|
  way.size >= 2
}


STDERR.puts "Build linestring"
@ends = Hash.new{ |h,k| h[k] = [] }

@ways.each{ |w|
  @ends[w[0]] << w
  @ends[w[-1]] << w
}

merge_linestring


STDERR.puts "Fill small gaps between ways"
points = []
@ways.each{ |way|
  points << way[0] + [way]
  points << way[-1] + [way]
}

kdtree = KDTree.new(points, 2)
black_list = []

@ends.select{ |k,v| v.size == 1 }.each{ |k,e|
  n = kdtree.nearest(k, 5e-6)
  if n
    n = n[0..1]
    if k != n and not black_list.include?([n,k]) # Dosen't add reverse segement
      way = [k,n]
      @ways << way
      @ends[k] << way
      @ends[n] << way
      black_list << way
    end
  end
}

merge_linestring

STDERR.puts "Prune"
@ends.select{ |k,v| v.size == 1 }.each{ |k,w|
  way = w[0]
  if way
    l = 0
    0.upto(way.size-2).each{ |i| l+= Math.sqrt( (way[i][0]-way[i+1][0])*(way[i][0]-way[i+1][0]) + (way[i][1]-way[i+1][1])*(way[i][1]-way[i+1][1]) ) }
    if l < 3e-4 # FIXME marche pour la Fance metrop
      @ends.delete(k)
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
