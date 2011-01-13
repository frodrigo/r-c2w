require 'rexml/document'
include REXML
require './script/kdtree.rb'
require 'set'


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

    def nearest(p, e, way)
        r = getInBox(p, e).sort!{ |p1,p2|
            p.dist(p1) <=> p.dist(p2)
        }.select{ |pp|
            p[2] != pp[2] # Reject all point from input way
        }.select{ |pp|
          way.all?{ |n| # Keep point not in input way
            not pp[2].include?(n)
          }
        }[0] # Take the nearest
    end
end


# --------- Main

file = File.new(ARGV[0])
water = ARGV[1] == 'water'
doc = Document.new(file)

@ways = Set.new
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
      w1 = e.to_a[0]
      w2 = e.to_a[1]
      if not w1 or not w2 or w1 == w2
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

def fill_gap(length)
  points = []
  @ways.each{ |way|
    points << way[0] + [way]
    points << way[-1] + [way]
  }
  kdtree = KDTree.new(points, 2)

  black_list = []
  @ends.select{ |k,v| v.size == 1 }.each{ |k,e|
    if e.size > 1
      next
    end
    n = kdtree.nearest(k, length, e.to_a[0])
    if n
      n = n[0..1]
      if k != n and not black_list.include?([k,n]) and not black_list.include?([n,k]) # Dosen't add reverse segement
        way = [k,n]
        @ways << way
        @ends[k] << way
        @ends[n] << way
        black_list << way
      end
    end
  }
end

def prune(length, loop=true)
  begin
    STDERR.puts "#{@ends.size} ends"
    touch = false
    @ends.select{ |k,v| v.size == 1 }.each{ |k,w|
      way = w.to_a[0]
      if way
        l = 0
        0.upto(way.size-2).each{ |i| l+= Math.sqrt( (way[i][0]-way[i+1][0])*(way[i][0]-way[i+1][0]) + (way[i][1]-way[i+1][1])*(way[i][1]-way[i+1][1]) ) }
        if l < length
          @ends[way[0]].delete(way)
          @ends[way[-1]].delete(way)
          @ends.delete(k)
          @ways.delete(way)
          touch = true
        end
      end
    }
    merge_linestring
  end while loop and touch
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
@ends = Hash.new{ |h,k| h[k] = Set.new }

@ways.each{ |w|
  @ends[w[0]] << w
  @ends[w[-1]] << w
}

STDERR.puts "Initial merge"
merge_linestring


STDERR.puts "Prune"
prune(1e-4, false) # Clean small thing

STDERR.puts "Fill small gaps between ways"
fill_gap(5e-6)
merge_linestring

STDERR.puts "Prune"
# FIXME marche pour la Fance metrop
prune(3e-4) # Clean for way


if water
  STDERR.puts "Fill gaps under water bridge"
  fill_gap(5e-4)
  merge_linestring
  prune(1e-3) # Large clean only for water
end

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
